using EmpManagementAPI2.DTOs.Department;
using EmpManagementAPI2.DTOs.Team;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Repository;

public class DepartmentRepository : IDepartmentRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public DepartmentRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // CREATE DEPARTMENT
    public async Task<bool> CreateDepartmentAsync(
        CreateDepartmentDto dto)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "CreateDepartment",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Name", dto.Name);
        command.Parameters.AddWithValue("@Description", dto.Description);

        object? result = await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }

    // GET ALL DEPARTMENTS
    public async Task<List<DepartmentListDto>> GetAllDepartmentsAsync()
    {
        List<DepartmentListDto> departments =
            new List<DepartmentListDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetAllDepartments",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            DepartmentListDto department =
                new DepartmentListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),
                    Name = reader["Name"].ToString() ?? string.Empty,
                    Description =
                        reader["Description"].ToString()
                        ?? string.Empty,
                    TotalEmployees =
                        Convert.ToInt32(reader["TotalEmployees"]),
                    TotalTeams =
                        Convert.ToInt32(reader["TotalTeams"]),
                    IsActive =
                        Convert.ToBoolean(reader["IsActive"])
                };

            departments.Add(department);
        }

        return departments;
    }

    // GET DEPARTMENT BY ID
    public async Task<DepartmentListDto?> GetDepartmentByIdAsync(
        int id)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetDepartmentById",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Id", id);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            DepartmentListDto department =
                new DepartmentListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),
                    Name = reader["Name"].ToString() ?? string.Empty,
                    Description =
                        reader["Description"].ToString()
                        ?? string.Empty,
                    TotalEmployees =
                        Convert.ToInt32(reader["TotalEmployees"]),
                    TotalTeams =
                        Convert.ToInt32(reader["TotalTeams"]),
                    IsActive =
                        Convert.ToBoolean(reader["IsActive"])
                };

            return department;
        }

        return null;
    }

    // GET DEPARTMENT COUNT
    public async Task<int> GetDepartmentCountAsync()
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetDepartmentCount",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        object? result = await command.ExecuteScalarAsync();

        return Convert.ToInt32(result);
    }

    // GET TEAMS BY DEPARTMENT
    public async Task<List<TeamListDto>> GetTeamsByDepartmentAsync(
        int departmentId)
    {
        List<TeamListDto> teams =
            new List<TeamListDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetTeamsByDepartment",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@DepartmentId",
            departmentId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            TeamListDto team =
                new TeamListDto
                {
                    Id = Convert.ToInt32(reader["Id"]),
                    Name = reader["Name"].ToString() ?? string.Empty,
                    EmployeeCount =
                        Convert.ToInt32(reader["EmployeeCount"]),
                    TeamHead =
                        reader["TeamHead"].ToString()
                        ?? string.Empty,
                    IsActive =
                        Convert.ToBoolean(reader["IsActive"])
                };

            teams.Add(team);
        }

        return teams;
    }

    // GET EMPLOYEES BY DEPARTMENT
    public async Task<List<DepartmentEmployeeDto>>
        GetEmployeesByDepartmentAsync(int departmentId)
    {
        List<DepartmentEmployeeDto> employees =
            new List<DepartmentEmployeeDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetEmployeesByDepartment",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@DepartmentId",
            departmentId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            DepartmentEmployeeDto employee =
                new DepartmentEmployeeDto
                {
                    Id = Convert.ToInt32(reader["Id"]),
                    Name = reader["Name"].ToString() ?? string.Empty,
                    Email = reader["Email"].ToString() ?? string.Empty,
                    Designation =
                        reader["Designation"].ToString()
                        ?? string.Empty,
                    Team =
                        reader["Team"].ToString()
                        ?? string.Empty,
                    IsActive =
                        Convert.ToBoolean(reader["IsActive"])
                };

            employees.Add(employee);
        }

        return employees;
    }
}