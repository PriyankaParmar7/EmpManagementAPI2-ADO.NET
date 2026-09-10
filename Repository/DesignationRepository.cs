using EmpManagementAPI2.DTOs.Designation;
using EmpManagementAPI2.Interfaces;
using Microsoft.Data.SqlClient;
using System.Data;

namespace EmpManagementAPI2.Repository;

public class DesignationRepository : IDesignationRepository
{
    private readonly IDbConnectionFactory _connectionFactory;

    public DesignationRepository(IDbConnectionFactory connectionFactory)
    {
        _connectionFactory = connectionFactory;
    }

    // CREATE DESIGNATION
    public async Task<bool> CreateDesignationAsync(CreateDesignationDto dto)
    {
        using SqlConnection connection = _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("CreateDesignation", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name.Trim());

        command.Parameters.AddWithValue(
            "@Description",
            string.IsNullOrWhiteSpace(dto.Description)
                ? DBNull.Value
                : dto.Description.Trim());

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }


    // GET ALL DESIGNATIONS
    public async Task<List<DesignationListDto>> GetAllDesignationsAsync()
    {
        List<DesignationListDto> designations =
            new List<DesignationListDto>();

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("GetAllDesignations", connection);

        command.CommandType = CommandType.StoredProcedure;

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            DesignationListDto designation =
                new DesignationListDto
                {
                    Id = reader.GetInt32(
                        reader.GetOrdinal("Id")),

                    Name = reader.GetString(
                        reader.GetOrdinal("Name")),

                    Description = reader.GetString(
                        reader.GetOrdinal("Description")),

                    IsActive = reader.GetBoolean(
                        reader.GetOrdinal("IsActive")),

                    EmployeeCount = reader.GetInt32(
                        reader.GetOrdinal("EmployeeCount"))
                };

            designations.Add(designation);
        }

        return designations;
    }


    // GET DESIGNATION BY ID
    public async Task<DesignationDetailsDto?> GetDesignationByIdAsync(
        int id)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("GetDesignationById", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Id", id);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        if (!await reader.ReadAsync())
        {
            return null;
        }

        DesignationDetailsDto designation =
            new DesignationDetailsDto
            {
                Id = reader.GetInt32(
                    reader.GetOrdinal("Id")),

                Name = reader.GetString(
                    reader.GetOrdinal("Name")),

                Description = reader.GetString(
                    reader.GetOrdinal("Description")),

                IsActive = reader.GetBoolean(
                    reader.GetOrdinal("IsActive")),

                EmployeeCount = reader.GetInt32(
                    reader.GetOrdinal("EmployeeCount"))
            };

        return designation;
    }


    // UPDATE DESIGNATION
    public async Task<bool> UpdateDesignationAsync(
        int id,
        UpdateDesignationDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("UpdateDesignation", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Id", id);

        command.Parameters.AddWithValue(
            "@Name",
            dto.Name.Trim());

        command.Parameters.AddWithValue(
            "@Description",
            string.IsNullOrWhiteSpace(dto.Description)
                ? DBNull.Value
                : dto.Description.Trim());

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }


    // DELETE DESIGNATION
    public async Task<bool> DeleteDesignationAsync(int id)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("DeleteDesignation", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Id", id);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }


    // UPDATE DESIGNATION STATUS
    public async Task<bool> UpdateDesignationStatusAsync(
        int id,
        UpdateDesignationStatusDto dto)
    {
        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand("UpdateDesignationStatus", connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue("@Id", id);

        command.Parameters.AddWithValue(
            "@IsActive",
            dto.IsActive);

        await connection.OpenAsync();

        object? result = await command.ExecuteScalarAsync();

        if (result == null || result == DBNull.Value)
        {
            return false;
        }

        return Convert.ToInt32(result) == 1;
    }


    // GET EMPLOYEES BY DESIGNATION
    public async Task<List<DesignationEmployeeDto>>
        GetEmployeesByDesignationAsync(int id)
    {
        List<DesignationEmployeeDto> employees =
            new List<DesignationEmployeeDto>();

        using SqlConnection connection =
            _connectionFactory.CreateConnection();

        using SqlCommand command =
            new SqlCommand(
                "GetEmployeesByDesignation",
                connection);

        command.CommandType = CommandType.StoredProcedure;

        command.Parameters.AddWithValue(
            "@DesignationId",
            id);

        await connection.OpenAsync();

        using SqlDataReader reader =
            await command.ExecuteReaderAsync();

        while (await reader.ReadAsync())
        {
            DesignationEmployeeDto employee =
                new DesignationEmployeeDto
                {
                    Id = reader.GetInt32(
                        reader.GetOrdinal("Id")),

                    Name = reader.GetString(
                        reader.GetOrdinal("Name")),

                    Email = reader.GetString(
                        reader.GetOrdinal("Email")),

                    DepartmentId =
                        reader.IsDBNull(
                            reader.GetOrdinal("DepartmentId"))
                            ? null
                            : reader.GetInt32(
                                reader.GetOrdinal("DepartmentId")),

                    TeamId =
                        reader.IsDBNull(
                            reader.GetOrdinal("TeamId"))
                            ? null
                            : reader.GetInt32(
                                reader.GetOrdinal("TeamId")),

                    IsActive = reader.GetBoolean(
                        reader.GetOrdinal("IsActive"))
                };

            employees.Add(employee);
        }

        return employees;
    }
}