using EmpManagementAPI2.DTOs.Auth;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Services;

public class SetupService : ISetupService
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IPasswordService _passwordService;

    public SetupService(
        IDbConnectionFactory connectionFactory,
        IPasswordService passwordService)
    {
        _connectionFactory = connectionFactory;
        _passwordService = passwordService;
    }

    public async Task<bool> CreateInitialAdminAsync(
        InitialAdminCreateDto dto)
    {
        // Create password hash and salt
        _passwordService.CreatePasswordHash(
            dto.Password,
            out byte[] passwordHash,
            out byte[] passwordSalt);

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand(
                "CreateInitialAdmin",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Username",
            dto.Username);

        command.Parameters.AddWithValue(
            "@Email",
            dto.Email);

        command.Parameters.AddWithValue(
            "@PasswordHash",
            passwordHash);

        command.Parameters.AddWithValue(
            "@PasswordSalt",
            passwordSalt);

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name);

        await connection.OpenAsync();

        object? result =
            await command.ExecuteScalarAsync();

        if (result == null ||
            result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }
}