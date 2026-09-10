using EmpManagementAPI2.DTOs.Designation;
using EmpManagementAPI2.Interfaces;

namespace EmpManagementAPI2.Services;

public class DesignationService : IDesignationService
{
    private readonly IDesignationRepository _designationRepository;

    public DesignationService(
        IDesignationRepository designationRepository)
    {
        _designationRepository = designationRepository;
    }

    // =========================================================
    // CREATE DESIGNATION
    // =========================================================

    public async Task<bool> CreateDesignationAsync(
        CreateDesignationDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            return false;
        }

        return await _designationRepository
            .CreateDesignationAsync(dto);
    }

    // =========================================================
    // GET ALL DESIGNATIONS
    // =========================================================

    public async Task<List<DesignationListDto>>
        GetAllDesignationsAsync()
    {
        return await _designationRepository
            .GetAllDesignationsAsync();
    }

    // =========================================================
    // GET DESIGNATION BY ID
    // =========================================================

    public async Task<DesignationDetailsDto?>
        GetDesignationByIdAsync(int id)
    {
        if (id <= 0)
        {
            return null;
        }

        return await _designationRepository
            .GetDesignationByIdAsync(id);
    }

    // =========================================================
    // UPDATE DESIGNATION
    // =========================================================

    public async Task<bool> UpdateDesignationAsync(
        int id,
        UpdateDesignationDto dto)
    {
        if (id <= 0)
        {
            return false;
        }

        if (string.IsNullOrWhiteSpace(dto.Name))
        {
            return false;
        }

        return await _designationRepository
            .UpdateDesignationAsync(id, dto);
    }

    // =========================================================
    // DELETE DESIGNATION
    // =========================================================

    public async Task<bool> DeleteDesignationAsync(int id)
    {
        if (id <= 0)
        {
            return false;
        }

        return await _designationRepository
            .DeleteDesignationAsync(id);
    }

    // =========================================================
    // UPDATE DESIGNATION STATUS
    // =========================================================

    public async Task<bool> UpdateDesignationStatusAsync(
        int id,
        UpdateDesignationStatusDto dto)
    {
        if (id <= 0)
        {
            return false;
        }

        return await _designationRepository
            .UpdateDesignationStatusAsync(id, dto);
    }

    // =========================================================
    // GET EMPLOYEES BY DESIGNATION
    // =========================================================

    public async Task<List<DesignationEmployeeDto>>
        GetEmployeesByDesignationAsync(int id)
    {
        if (id <= 0)
        {
            return new List<DesignationEmployeeDto>();
        }

        return await _designationRepository
            .GetEmployeesByDesignationAsync(id);
    }
}