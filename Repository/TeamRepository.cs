using EmpManagementAPI2.DTOs.Team;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Repository;

public class TeamRepository : ITeamRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public TeamRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // CREATE TEAM
    public async Task<bool> CreateTeamAsync(CreateTeamDto dto)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "CreateTeam",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name);

        command.Parameters.AddWithValue(
            "@DepartmentId",
            dto.DepartmentId);

        object? result = await command.ExecuteScalarAsync();

        return Convert.ToInt32(result) == 1;
    }

    // GET ALL TEAMS
    public async Task<List<TeamListDto>> GetAllTeamsAsync()
    {
        List<TeamListDto> teams = new List<TeamListDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetAllTeams",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            TeamListDto team = new TeamListDto
            {
                Id = Convert.ToInt32(reader["Id"]),

                Name = reader["Name"]
                    .ToString() ?? string.Empty,

                EmployeeCount = Convert.ToInt32(
                    reader["EmployeeCount"]),

                TeamHead = reader["TeamHead"]
                    .ToString() ?? string.Empty,

                IsActive = Convert.ToBoolean(
                    reader["IsActive"])
            };

            teams.Add(team);
        }

        return teams;
    }

    // GET TEAM BY ID
    public async Task<TeamDetailsDto?> GetTeamByIdAsync(int id)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetTeamById",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Id",
            id);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (await reader.ReadAsync())
        {
            TeamDetailsDto team = new TeamDetailsDto
            {
                Id = Convert.ToInt32(reader["Id"]),

                Name = reader["Name"]
                    .ToString() ?? string.Empty,

                DepartmentId = Convert.ToInt32(
                    reader["DepartmentId"]),

                Department = reader["Department"]
                    .ToString() ?? string.Empty,

                TeamHeadEmployeeId =
                    reader["TeamHeadEmployeeId"] == DBNull.Value
                        ? null
                        : Convert.ToInt32(
                            reader["TeamHeadEmployeeId"]),

                TeamHead = reader["TeamHead"]
                    .ToString() ?? string.Empty,

                EmployeeCount = Convert.ToInt32(
                    reader["EmployeeCount"]),

                IsActive = Convert.ToBoolean(
                    reader["IsActive"])
            };

            return team;
        }

        return null;
    }

    // GET EMPLOYEES BY TEAM
    public async Task<List<TeamEmployeeDto>> GetEmployeesByTeamAsync(
        int teamId)
    {
        List<TeamEmployeeDto> employees =
            new List<TeamEmployeeDto>();

        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetEmployeesByTeam",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@TeamId",
            teamId);

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            TeamEmployeeDto employee =
                new TeamEmployeeDto
                {
                    Id = Convert.ToInt32(
                        reader["Id"]),

                    Name = reader["Name"]
                        .ToString() ?? string.Empty,

                    Email = reader["Email"]
                        .ToString() ?? string.Empty,

                    Designation = reader["Designation"]
                        .ToString() ?? string.Empty,

                    IsActive = Convert.ToBoolean(
                        reader["IsActive"])
                };

            employees.Add(employee);
        }

        return employees;
    }

    // GET TOTAL TEAM COUNT
    public async Task<int> GetTeamCountAsync()
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        await connection.OpenAsync();

        using SqlCommand command = new SqlCommand(
            "GetTeamCount",
            connection);

        command.CommandType = CommandType.StoredProcedure;

        object? result = await command.ExecuteScalarAsync();

        return Convert.ToInt32(result);
    }
}