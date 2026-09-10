using EmpManagementAPI2.DTOs.Auth;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using Microsoft.IdentityModel.Tokens;
using System.Data;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace EmpManagementAPI2.Services;

public class AuthService : IAuthService
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IPasswordService _passwordService;
    private readonly IConfiguration _configuration;
    private readonly IEmailService _emailService;

    public AuthService(
        IDbConnectionFactory connectionFactory,
        IPasswordService passwordService,
        IConfiguration configuration,
        IEmailService emailService)
    {
        _connectionFactory = connectionFactory;
        _passwordService = passwordService;
        _configuration = configuration;
        _emailService = emailService;
    }

    // LOGIN
    public async Task<string?> LoginAsync(
        string username,
        string password)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("LoginUser", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Username",
            username);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        int userId =
            reader.GetInt32(
                reader.GetOrdinal("Id"));

        string dbUsername =
            reader.GetString(
                reader.GetOrdinal("Username"));

        byte[] passwordHash =
            (byte[])reader["PasswordHash"];

        byte[] passwordSalt =
            (byte[])reader["PasswordSalt"];

        bool isActive =
            reader.GetBoolean(
                reader.GetOrdinal("IsActive"));

        string roleName =
            reader.GetString(
                reader.GetOrdinal("RoleName"));

        // Check account status
        if (!isActive)
        {
            return null;
        }

        // Verify password
        bool passwordValid =
            _passwordService.VerifyPassword(
                password,
                passwordHash,
                passwordSalt);

        if (!passwordValid)
        {
            return null;
        }

        // Create JWT claims
        List<Claim> claims =
            new List<Claim>
            {
                new Claim(
                    ClaimTypes.NameIdentifier,
                    userId.ToString()),

                new Claim(
                    ClaimTypes.Name,
                    dbUsername),

                new Claim(
                    ClaimTypes.Role,
                    roleName)
            };

        // Get JWT settings
        string key =
            _configuration["Jwt:Key"]!;

        SymmetricSecurityKey securityKey =
            new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(key));

        SigningCredentials credentials =
            new SigningCredentials(
                securityKey,
                SecurityAlgorithms.HmacSha256);

        // Create JWT
        JwtSecurityToken token =
            new JwtSecurityToken(
                issuer:
                    _configuration["Jwt:Issuer"],

                audience:
                    _configuration["Jwt:Audience"],

                claims: claims,

                expires:
                    DateTime.UtcNow.AddMinutes(
                        Convert.ToDouble(
                            _configuration[
                                "Jwt:ExpiryMinutes"])),

                signingCredentials:
                    credentials);

        return new JwtSecurityTokenHandler()
            .WriteToken(token);
    }


    // CHANGE PASSWORD
    public async Task<bool> ChangePasswordAsync(
        int userId,
        ChangePasswordDto dto)
    {
        // Check password confirmation
        if (dto.NewPassword != dto.ConfirmPassword)
        {
            return false;
        }

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        // Get current password
        using SqlCommand command =
            new SqlCommand(
                "GetUserForPasswordChange",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@UserId",
            userId);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return false;
        }

        byte[] currentPasswordHash =
            (byte[])reader["PasswordHash"];

        byte[] currentPasswordSalt =
            (byte[])reader["PasswordSalt"];

        // Verify current password
        bool passwordValid =
            _passwordService.VerifyPassword(
                dto.CurrentPassword,
                currentPasswordHash,
                currentPasswordSalt);

        if (!passwordValid)
        {
            return false;
        }

        // Create new password hash and salt
        _passwordService.CreatePasswordHash(
            dto.NewPassword,
            out byte[] newPasswordHash,
            out byte[] newPasswordSalt);

        await reader.CloseAsync();

        // Update password
        using SqlCommand updateCommand =
            new SqlCommand(
                "ChangeUserPassword",
                connection);

        updateCommand.CommandType =
            CommandType.StoredProcedure;

        updateCommand.Parameters.AddWithValue(
            "@UserId",
            userId);

        updateCommand.Parameters.AddWithValue(
            "@PasswordHash",
            newPasswordHash);

        updateCommand.Parameters.AddWithValue(
            "@PasswordSalt",
            newPasswordSalt);

        object? result =
            await updateCommand.ExecuteScalarAsync();

        if (result == null ||
            result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }


    // FORGOT PASSWORD
    public async Task<bool> ForgotPasswordAsync(
        ForgotPasswordDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        // Find user by email
        using SqlCommand command =
            new SqlCommand(
                "GetUserByEmail",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Email",
            dto.Email);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        // Don't reveal whether email exists
        if (!await reader.ReadAsync())
        {
            return true;
        }

        int userId =
            reader.GetInt32(
                reader.GetOrdinal("Id"));

        string email =
            reader.GetString(
                reader.GetOrdinal("Email"));

        // Generate temporary password
        const string characters =
            "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789";

        string temporaryPassword =
            new string(
                Enumerable.Range(0, 10)
                    .Select(
                        _ =>
                            characters[
                                System.Security.Cryptography
                                    .RandomNumberGenerator
                                    .GetInt32(
                                        characters.Length)])
                    .ToArray());

        // Create hash and salt
        _passwordService.CreatePasswordHash(
            temporaryPassword,
            out byte[] passwordHash,
            out byte[] passwordSalt);

        await reader.CloseAsync();

        // Update password
        using SqlCommand updateCommand =
            new SqlCommand(
                "ChangeUserPassword",
                connection);

        updateCommand.CommandType =
            CommandType.StoredProcedure;

        updateCommand.Parameters.AddWithValue(
            "@UserId",
            userId);

        updateCommand.Parameters.AddWithValue(
            "@PasswordHash",
            passwordHash);

        updateCommand.Parameters.AddWithValue(
            "@PasswordSalt",
            passwordSalt);

        object? result =
            await updateCommand.ExecuteScalarAsync();

        if (result == null ||
            result == DBNull.Value ||
            Convert.ToInt32(result) != 1)
        {
            return false;
        }

        // Send temporary password
        try
        {
            await _emailService.SendPasswordResetEmailAsync(
                email,
                temporaryPassword);

            Console.WriteLine(
                "PASSWORD RESET EMAIL SENT SUCCESSFULLY.");
        }
        catch (Exception ex)
        {
            Console.WriteLine(
                "PASSWORD RESET EMAIL ERROR:");

            Console.WriteLine(
                ex.ToString());

            throw;
        }

        return true;
    }
}