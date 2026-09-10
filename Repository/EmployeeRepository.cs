using EmpManagementAPI2.DTOs.Employee;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Repository;

public class EmployeeRepository : IEmployeeRepository
{
    private readonly IDbConnectionFactory _connectionFactory;
    private readonly IPasswordService _passwordService;

    public EmployeeRepository(
        IDbConnectionFactory connectionFactory,
        IPasswordService passwordService)
    {
        _connectionFactory = connectionFactory;
        _passwordService = passwordService;
    }

    // =========================================================
    // CREATE EMPLOYEE
    // =========================================================

    public async Task<bool> CreateEmployeeAsync(
        CreateEmployeeDto dto,
        string temporaryPassword)
    {
        _passwordService.CreatePasswordHash(
            temporaryPassword,
            out byte[] passwordHash,
            out byte[] passwordSalt);

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("CreateEmployee", connection);

        command.CommandType = CommandType.StoredProcedure;

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

        command.Parameters.AddWithValue(
            "@DepartmentId",
            dto.DepartmentId.HasValue
                ? dto.DepartmentId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@TeamId",
            dto.TeamId.HasValue
                ? dto.TeamId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@SupervisorId",
            dto.SupervisorId.HasValue
                ? dto.SupervisorId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@DesignationId",
            dto.DesignationId);

        command.Parameters.AddWithValue(
            "@RoleId",
            dto.RoleId);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // GET ALL EMPLOYEES
    // SEARCH + FILTER + PAGINATION
    // =========================================================

    public async Task<EmployeePagedResultDto> GetAllEmployeesAsync(
        EmployeeFilterDto filter)
    {
        if (filter.Page < 1)
        {
            filter.Page = 1;
        }

        if (filter.PageSize < 1)
        {
            filter.PageSize = 20;
        }

        if (filter.PageSize > 100)
        {
            filter.PageSize = 100;
        }

        if (!string.IsNullOrWhiteSpace(filter.Search))
        {
            filter.Search = filter.Search.Trim();
        }

        if (!string.IsNullOrWhiteSpace(filter.Status))
        {
            filter.Status = filter.Status.Trim();
        }

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("GetAllEmployees", connection);

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
            "@DepartmentId",
            filter.DepartmentId.HasValue
                ? filter.DepartmentId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@TeamId",
            filter.TeamId.HasValue
                ? filter.TeamId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@DesignationId",
            filter.DesignationId.HasValue
                ? filter.DesignationId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@SupervisorId",
            filter.SupervisorId.HasValue
                ? filter.SupervisorId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@SortBy",
            filter.SortBy);

        command.Parameters.AddWithValue(
            "@SortDescending",
            filter.SortDescending);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        int totalRecords = 0;

        // First result set contains TotalRecords
        if (await reader.ReadAsync())
        {
            totalRecords =
                Convert.ToInt32(reader["TotalRecords"]);
        }

        List<EmployeeListDto> employees =
            new List<EmployeeListDto>();

        // Move to second result set
        await reader.NextResultAsync();

        while (await reader.ReadAsync())
        {
            EmployeeListDto employee =
                new EmployeeListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),

                    Name =
                        reader["Name"].ToString()
                        ?? string.Empty,

                    Email =
                        reader["Email"].ToString()
                        ?? string.Empty,

                    Department =
                        reader["Department"].ToString()
                        ?? string.Empty,

                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,

                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,

                    Supervisor =
                        reader["Supervisor"].ToString()
                        ?? string.Empty,

                    IsActive =
                        Convert.ToBoolean(
                            reader["IsActive"])
                };

            employees.Add(employee);
        }

        int totalPages =
            totalRecords == 0
                ? 0
                : (int)Math.Ceiling(
                    totalRecords /
                    (double)filter.PageSize);

        return new EmployeePagedResultDto
        {
            Employees = employees,
            Page = filter.Page,
            PageSize = filter.PageSize,
            TotalRecords = totalRecords,
            TotalPages = totalPages
        };
    }


    // =========================================================
    // GET EMPLOYEE BY ID
    // =========================================================

    public async Task<EmployeeListDto?> GetEmployeeByIdAsync(
        int id)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("GetEmployeeById", connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            EmployeeListDto employee =
                new EmployeeListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),

                    Name =
                        reader["Name"].ToString()
                        ?? string.Empty,

                    Email =
                        reader["Email"].ToString()
                        ?? string.Empty,

                    Department =
                        reader["Department"].ToString()
                        ?? string.Empty,

                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,

                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,

                    Supervisor =
                        reader["Supervisor"].ToString()
                        ?? string.Empty,

                    IsActive =
                        Convert.ToBoolean(
                            reader["IsActive"])
                };

            return employee;
        }

        return null;
    }


    // =========================================================
    // UPDATE EMPLOYEE
    // =========================================================

    public async Task<bool> UpdateEmployeeAsync(
        int id,
        UpdateEmployeeDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("UpdateEmployee", connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name);

        command.Parameters.AddWithValue(
            "@Email",
            dto.Email);

        command.Parameters.AddWithValue(
            "@DepartmentId",
            dto.DepartmentId.HasValue
                ? dto.DepartmentId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@TeamId",
            dto.TeamId.HasValue
                ? dto.TeamId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@SupervisorId",
            dto.SupervisorId.HasValue
                ? dto.SupervisorId.Value
                : DBNull.Value);

        command.Parameters.AddWithValue(
            "@DesignationId",
            dto.DesignationId);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // DELETE EMPLOYEE
    // =========================================================

    public async Task<bool> DeleteEmployeeAsync(int id)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("DeleteEmployee", connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // GET EMPLOYEE COUNT
    // =========================================================

    public async Task<int> GetEmployeeCountAsync()
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand("GetEmployeeCount", connection);

        command.CommandType =
            CommandType.StoredProcedure;

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result);
    }


    // =========================================================
    // UPDATE EMPLOYEE STATUS
    // =========================================================

    public async Task<bool> UpdateEmployeeStatusAsync(
        int id,
        UpdateEmployeeStatusDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateEmployeeStatus",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@IsActive",
            dto.IsActive);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // GET MY PROFILE
    // =========================================================

    public async Task<EmployeeListDto?> GetMyProfileAsync(
        int userId)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "GetMyProfile",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@UserId",
            userId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            EmployeeListDto employee =
                new EmployeeListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),

                    Name =
                        reader["Name"].ToString()
                        ?? string.Empty,

                    Email =
                        reader["Email"].ToString()
                        ?? string.Empty,

                    Department =
                        reader["Department"].ToString()
                        ?? string.Empty,

                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,

                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,

                    Supervisor =
                        reader["Supervisor"].ToString()
                        ?? string.Empty,

                    IsActive =
                        Convert.ToBoolean(
                            reader["IsActive"])
                };

            return employee;
        }

        return null;
    }


    // =========================================================
    // UPDATE MY PROFILE
    // =========================================================

    public async Task<bool> UpdateMyProfileAsync(
        int userId,
        UpdateMyProfileDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateMyProfile",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@UserId",
            userId);

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name);

        command.Parameters.AddWithValue(
            "@Email",
            dto.Email);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // UPDATE EMPLOYEE DEPARTMENT
    // =========================================================

    public async Task<bool> UpdateEmployeeDepartmentAsync(
        int id,
        UpdateEmployeeDepartmentDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateEmployeeDepartment",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@DepartmentId",
            dto.DepartmentId.HasValue
                ? dto.DepartmentId.Value
                : DBNull.Value);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // UPDATE EMPLOYEE TEAM
    // =========================================================

    public async Task<bool> UpdateEmployeeTeamAsync(
        int id,
        UpdateEmployeeTeamDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateEmployeeTeam",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@TeamId",
            dto.TeamId.HasValue
                ? dto.TeamId.Value
                : DBNull.Value);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // UPDATE EMPLOYEE SUPERVISOR
    // =========================================================

    public async Task<bool> UpdateEmployeeSupervisorAsync(
        int id,
        UpdateEmployeeSupervisorDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateEmployeeSupervisor",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@SupervisorId",
            dto.SupervisorId.HasValue
                ? dto.SupervisorId.Value
                : DBNull.Value);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // UPDATE EMPLOYEE DESIGNATION
    // =========================================================

    public async Task<bool> UpdateEmployeeDesignationAsync(
        int id,
        UpdateEmployeeDesignationDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "UpdateEmployeeDesignation",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        command.Parameters.AddWithValue(
            "@DesignationId",
            dto.DesignationId);

        object? result =
            await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }


    // =========================================================
    // GET SUBORDINATES
    // =========================================================

    public async Task<List<EmployeeSubordinateDto>>
        GetSubordinatesAsync(int employeeId)
    {
        List<EmployeeSubordinateDto> employees =
            new List<EmployeeSubordinateDto>();

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "GetSubordinates",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            EmployeeSubordinateDto employee =
                new EmployeeSubordinateDto
                {
                    Id = Convert.ToInt32(reader["Id"]),

                    Name =
                        reader["Name"].ToString()
                        ?? string.Empty,

                    Email =
                        reader["Email"].ToString()
                        ?? string.Empty,

                    Department =
                        reader["Department"].ToString()
                        ?? string.Empty,

                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,

                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,

                    IsActive =
                        Convert.ToBoolean(
                            reader["IsActive"])
                };

            employees.Add(employee);
        }

        return employees;
    }


    // =========================================================
    // GET SUPERVISOR
    // =========================================================

    public async Task<EmployeeSupervisorDto?>
        GetSupervisorAsync(int employeeId)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command =
            new SqlCommand(
                "GetSupervisor",
                connection);

        command.CommandType =
            CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@EmployeeId",
            employeeId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            EmployeeSupervisorDto supervisor =
                new EmployeeSupervisorDto
                {
                    Id = Convert.ToInt32(reader["Id"]),

                    Name =
                        reader["Name"].ToString()
                        ?? string.Empty,

                    Email =
                        reader["Email"].ToString()
                        ?? string.Empty,

                    Department =
                        reader["Department"].ToString()
                        ?? string.Empty,

                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,

                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,

                    IsActive =
                        Convert.ToBoolean(
                            reader["IsActive"])
                };

            return supervisor;
        }

        return null;
    }
}