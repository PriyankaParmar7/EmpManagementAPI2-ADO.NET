using EmpManagementAPI2.DTOs.Leave;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Repository;

public class LeaveRepository : ILeaveRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public LeaveRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // CREATE LEAVE
    public async Task<LeaveResponseDto?> CreateLeaveAsync(
        int employeeId,
        CreateLeaveRequestDto dto)
    {
        if (dto.IsTeamLeave && dto.TeamId == null)
        {
            return null;
        }

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "CreateLeave",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        command.Parameters.AddWithValue(
            "@LeaveType",
            dto.LeaveType);

        command.Parameters.AddWithValue(
            "@Reason",
            dto.Reason);

        command.Parameters.AddWithValue(
            "@StartDate",
            dto.StartDate);

        command.Parameters.AddWithValue(
            "@EndDate",
            dto.EndDate);

        command.Parameters.AddWithValue(
            "@IsTeamLeave",
            dto.IsTeamLeave);

        command.Parameters.AddWithValue(
            "@TeamId",
            dto.TeamId.HasValue
                ? dto.TeamId.Value
                : DBNull.Value);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return null;
        }

        int leaveId = Convert.ToInt32(result);

        return await GetLeaveByIdAsync(leaveId);
    }

    // GET MY LEAVES
    public async Task<List<LeaveResponseDto>> GetMyLeavesAsync(
        int employeeId)
    {
        List<LeaveResponseDto> leaves = new List<LeaveResponseDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetMyLeaves",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            leaves.Add(MapLeave(reader));
        }

        return leaves;
    }

    // GET LEAVE BY ID
    public async Task<LeaveResponseDto?> GetLeaveByIdAsync(
        int leaveId)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetLeaveById",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@LeaveId",
            leaveId);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        return MapLeave(reader);
    }

    // GET ALL LEAVES
    public async Task<List<LeaveResponseDto>> GetAllLeavesAsync()
    {
        List<LeaveResponseDto> leaves = new List<LeaveResponseDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetAllLeaves",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            leaves.Add(MapLeave(reader));
        }

        return leaves;
    }

    // GET PENDING LEAVES
    public async Task<List<LeaveResponseDto>> GetPendingLeavesAsync()
    {
        List<LeaveResponseDto> leaves = new List<LeaveResponseDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetPendingLeaves",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            leaves.Add(MapLeave(reader));
        }

        return leaves;
    }

    // GET TEAM LEAVES
    public async Task<List<LeaveResponseDto>> GetTeamLeavesAsync(
        int employeeId)
    {
        List<LeaveResponseDto> leaves = new List<LeaveResponseDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetTeamLeaves",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            leaves.Add(MapLeave(reader));
        }

        return leaves;
    }

    // APPROVE LEAVE
    public async Task<bool> ApproveLeaveAsync(
        int leaveId,
        int approvedBy)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "ApproveLeave",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@LeaveId",
            leaveId);

        command.Parameters.AddWithValue(
            "@ApprovedBy",
            approvedBy);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }

    // REJECT LEAVE
    public async Task<bool> RejectLeaveAsync(
        int leaveId,
        int rejectedBy,
        string? reason)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "RejectLeave",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@LeaveId",
            leaveId);

        command.Parameters.AddWithValue(
            "@RejectedBy",
            rejectedBy);

        command.Parameters.AddWithValue(
            "@Reason",
            string.IsNullOrWhiteSpace(reason)
                ? DBNull.Value
                : reason);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }

    // GET EMPLOYEE ID FROM APP USER ID
    public async Task<int?> GetEmployeeIdByAppUserIdAsync(
        int appUserId)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "GetEmployeeIdByAppUserId",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@AppUserId",
            appUserId);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return null;
        }

        return Convert.ToInt32(result);
    }

    // CANCEL LEAVE
    public async Task<bool> CancelLeaveAsync(
        int leaveId,
        int userId)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "CancelLeave",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@LeaveId",
            leaveId);

        command.Parameters.AddWithValue(
            "@UserId",
            userId);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }

    // SEARCH / FILTER / PAGINATION
    public async Task<LeavePagedResultDto> SearchLeavesAsync(
        LeaveFilterDto filter)
    {
        if (filter.Page < 1)
        {
            filter.Page = 1;
        }

        if (filter.PageSize < 1)
        {
            filter.PageSize = 10;
        }

        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command = new SqlCommand(
            "SearchLeaves",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Page",
            filter.Page);

        command.Parameters.AddWithValue(
            "@PageSize",
            filter.PageSize);

        command.Parameters.AddWithValue(
            "@Search",
            string.IsNullOrWhiteSpace(filter.Search)
                ? DBNull.Value
                : filter.Search);

        command.Parameters.AddWithValue(
            "@Status",
            string.IsNullOrWhiteSpace(filter.Status)
                ? DBNull.Value
                : filter.Status);

        command.Parameters.AddWithValue(
            "@EmployeeId",
            filter.EmployeeId.HasValue
                ? filter.EmployeeId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@TeamId",
            filter.TeamId.HasValue
                ? filter.TeamId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@LeaveType",
            string.IsNullOrWhiteSpace(filter.LeaveType)
                ? DBNull.Value
                : filter.LeaveType);

        command.Parameters.AddWithValue(
            "@FromDate",
            filter.FromDate.HasValue
                ? filter.FromDate.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@ToDate",
            filter.ToDate.HasValue
                ? filter.ToDate.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@SortBy",
            string.IsNullOrWhiteSpace(filter.SortBy)
                ? DBNull.Value
                : filter.SortBy);

        command.Parameters.AddWithValue(
            "@SortDescending",
            filter.SortDescending);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        int totalRecords = 0;

        if (await reader.ReadAsync())
        {
            totalRecords = reader.GetInt32(0);
        }

        List<LeaveResponseDto> leaves =
            new List<LeaveResponseDto>();

        if (await reader.NextResultAsync())
        {
            while (await reader.ReadAsync())
            {
                leaves.Add(MapLeave(reader));
            }
        }

        int totalPages = (int)Math.Ceiling(
            totalRecords / (double)filter.PageSize);

        return new LeavePagedResultDto
        {
            Leaves = leaves,
            Page = filter.Page,
            PageSize = filter.PageSize,
            TotalRecords = totalRecords,
            TotalPages = totalPages
        };
    }

    // COMMON MAPPING METHOD
    private static LeaveResponseDto MapLeave(
        SqlDataReader reader)
    {
        return new LeaveResponseDto
        {
            Id = reader.GetInt32(
                reader.GetOrdinal("Id")),

            EmployeeId = reader.GetInt32(
                reader.GetOrdinal("EmployeeId")),

            EmployeeName = reader.GetString(
                reader.GetOrdinal("EmployeeName")),

            LeaveType = reader.GetString(
                reader.GetOrdinal("LeaveType")),

            Reason = reader.GetString(
                reader.GetOrdinal("Reason")),

            StartDate = reader.GetDateTime(
                reader.GetOrdinal("StartDate")),

            EndDate = reader.GetDateTime(
                reader.GetOrdinal("EndDate")),

            Status = reader.GetString(
                reader.GetOrdinal("Status")),

            IsTeamLeave = reader.GetBoolean(
                reader.GetOrdinal("IsTeamLeave")),

            TeamId = reader.IsDBNull(
                reader.GetOrdinal("TeamId"))
                ? null
                : reader.GetInt32(
                    reader.GetOrdinal("TeamId")),

            TeamName = reader.GetString(
                reader.GetOrdinal("TeamName")),

            ApprovedBy = reader.IsDBNull(
                reader.GetOrdinal("ApprovedBy"))
                ? null
                : reader.GetInt32(
                    reader.GetOrdinal("ApprovedBy")),

            ApprovedByName = reader.GetString(
                reader.GetOrdinal("ApprovedByName")),

            ApprovedDate = reader.IsDBNull(
                reader.GetOrdinal("ApprovedDate"))
                ? null
                : reader.GetDateTime(
                    reader.GetOrdinal("ApprovedDate")),

            CreatedAt = reader.GetDateTime(
                reader.GetOrdinal("CreatedAt"))
        };
    }
}