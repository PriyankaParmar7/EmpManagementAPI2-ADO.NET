using System.Data;
using System.Net;
using System.Net.Mail;
using EmpManagementAPI2.DTOs.Leave;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;

namespace EmpManagementAPI2.Services;

public class EmailService : IEmailService
{
    private readonly IConfiguration _configuration;
    private readonly IDbConnectionFactory _connectionFactory;

    public EmailService(
        IConfiguration configuration,
        IDbConnectionFactory connectionFactory)
    {
        _configuration = configuration;
        _connectionFactory = connectionFactory;
    }

    // =========================================================
    // EMPLOYEE CREDENTIALS
    // =========================================================

    public async Task SendEmployeeCredentialsAsync(
        string email,
        string username,
        string temporaryPassword)
    {
        string subject =
            "Employee Management System - Your Account";

        string body = $"""
            <h2>Welcome to Employee Management System</h2>

            <p>Your employee account has been created.</p>

            <p>
                <strong>Username:</strong> {username}
            </p>

            <p>
                <strong>Temporary Password:</strong>
                {temporaryPassword}
            </p>

            <p>Please use these credentials to log in.</p>

            <p>
                Regards,<br/>
                Employee Management System
            </p>
            """;

        await SendEmailAsync(
            email,
            subject,
            body);
    }


    // =========================================================
    // NEW LEAVE REQUEST → HR
    // =========================================================

    public async Task SendLeaveRequestNotificationAsync(
        LeaveResponseDto leave)
    {
        List<string> hrEmails =
            new List<string>();

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand(
                "GetHREmails",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            if (!reader.IsDBNull(
                    reader.GetOrdinal("Email")))
            {
                string hrEmail =
                    reader.GetString(
                        reader.GetOrdinal("Email"));

                if (!string.IsNullOrWhiteSpace(hrEmail))
                {
                    hrEmails.Add(hrEmail);
                }
            }
        }

        if (hrEmails.Count == 0)
        {
            return;
        }

        string subject =
            "New Leave Request";

        string body = $"""
            <h2>New Leave Request</h2>

            <p>A new leave request has been submitted.</p>

            <p>
                <strong>Employee:</strong>
                {leave.EmployeeName}
            </p>

            <p>
                <strong>Leave Type:</strong>
                {leave.LeaveType}
            </p>

            <p>
                <strong>Start Date:</strong>
                {leave.StartDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>End Date:</strong>
                {leave.EndDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>Reason:</strong>
                {leave.Reason}
            </p>

            <p>
                <strong>Status:</strong>
                Pending
            </p>

            <p>
                Please log in to the Employee Management System
                to review the request.
            </p>
            """;

        foreach (string hrEmail in hrEmails)
        {
            await SendEmailAsync(
                hrEmail,
                subject,
                body);
        }
    }


    // =========================================================
    // LEAVE APPROVED → EMPLOYEE
    // =========================================================

    public async Task SendLeaveApprovedEmailAsync(
        LeaveResponseDto leave)
    {
        string? employeeEmail =
            await GetEmployeeEmailAsync(
                leave.EmployeeId);

        if (string.IsNullOrWhiteSpace(employeeEmail))
        {
            return;
        }

        string subject =
            "Leave Request Approved";

        string body = $"""
            <h2>Leave Request Approved</h2>

            <p>Hello {leave.EmployeeName},</p>

            <p>
                Your leave request has been
                <strong>approved</strong>.
            </p>

            <p>
                <strong>Leave Type:</strong>
                {leave.LeaveType}
            </p>

            <p>
                <strong>Start Date:</strong>
                {leave.StartDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>End Date:</strong>
                {leave.EndDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>Approved By:</strong>
                {leave.ApprovedByName}
            </p>

            <p>
                Regards,<br/>
                Employee Management System
            </p>
            """;

        await SendEmailAsync(
            employeeEmail,
            subject,
            body);
    }


    // =========================================================
    // LEAVE REJECTED → EMPLOYEE
    // =========================================================

    public async Task SendLeaveRejectedEmailAsync(
        LeaveResponseDto leave)
    {
        string? employeeEmail =
            await GetEmployeeEmailAsync(
                leave.EmployeeId);

        if (string.IsNullOrWhiteSpace(employeeEmail))
        {
            return;
        }

        string subject =
            "Leave Request Rejected";

        string body = $"""
            <h2>Leave Request Rejected</h2>

            <p>Hello {leave.EmployeeName},</p>

            <p>
                Your leave request has been
                <strong>rejected</strong>.
            </p>

            <p>
                <strong>Leave Type:</strong>
                {leave.LeaveType}
            </p>

            <p>
                <strong>Start Date:</strong>
                {leave.StartDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>End Date:</strong>
                {leave.EndDate:dd-MM-yyyy}
            </p>

            <p>
                <strong>Reason:</strong>
                {leave.Reason}
            </p>

            <p>
                Please contact HR if you have any questions.
            </p>

            <p>
                Regards,<br/>
                Employee Management System
            </p>
            """;

        await SendEmailAsync(
            employeeEmail,
            subject,
            body);
    }


    // =========================================================
    // GET EMPLOYEE EMAIL
    // =========================================================

    private async Task<string?> GetEmployeeEmailAsync(
        int employeeId)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand(
                "GetEmployeeEmail",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        await connection.OpenAsync();

        object? result =
            await command.ExecuteScalarAsync();

        if (result == null ||
            result == DBNull.Value)
        {
            return null;
        }

        return result.ToString();
    }


    // =========================================================
    // COMMON EMAIL METHOD
    // =========================================================

    private async Task SendEmailAsync(
        string receiverEmail,
        string subject,
        string body)
    {
        IConfigurationSection emailSettings =
            _configuration.GetSection(
                "EmailSettings");

        string smtpServer =
            emailSettings["SmtpServer"]!;

        int port =
            int.Parse(
                emailSettings["Port"]!);

        string senderEmail =
            emailSettings["SenderEmail"]!;

        string username =
            emailSettings["Username"]!;

        string password =
            emailSettings["Password"]!;

        string senderName =
            emailSettings["SenderName"]!;

        using MailMessage message =
            new MailMessage();

        message.From =
            new MailAddress(
                senderEmail,
                senderName);

        message.To.Add(receiverEmail);

        message.Subject =
            subject;

        message.Body =
            body;

        message.IsBodyHtml =
            true;

        using SmtpClient smtpClient =
            new SmtpClient(
                smtpServer,
                port);

        smtpClient.EnableSsl =
            true;

        smtpClient.Credentials =
            new NetworkCredential(
                username,
                password);

        await smtpClient.SendMailAsync(
            message);
    }


    // =========================================================
    // PASSWORD RESET
    // =========================================================

    public async Task SendPasswordResetEmailAsync(
        string email,
        string temporaryPassword)
    {
        string subject =
            "Employee Management System - Temporary Password";

        string body = $"""
            <h2>Password Reset</h2>

            <p>
                We received a request to reset your password.
            </p>

            <p>
                Your temporary password is:
            </p>

            <p>
                <strong>{temporaryPassword}</strong>
            </p>

            <p>
                You can use this temporary password to log in to
                the Employee Management System.
            </p>

            <p>
                After logging in, you can change your password
                using the Change Password option.
            </p>

            <p>
                If you did not request a password reset,
                please contact the administrator.
            </p>

            <p>
                Regards,<br/>
                Employee Management System
            </p>
            """;

        await SendEmailAsync(
            email,
            subject,
            body);
    }
}