using EmpManagementAPI2.DTOs.Designation;
using EmpManagementAPI2.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EmpManagementAPI2.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DesignationController : ControllerBase
{
    private readonly IDesignationService _designationService;

    public DesignationController(
        IDesignationService designationService)
    {
        _designationService = designationService;
    }

    // =========================================================
    // CREATE DESIGNATION
    // POST: api/Designation
    // Admin only
    // =========================================================

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> CreateDesignation(
        CreateDesignationDto dto)
    {
        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        bool result = await _designationService.CreateDesignationAsync(dto);

        if (!result)
        {
            return Conflict(
                "Designation already exists or could not be created.");
        }

        return Ok(
            "Designation created successfully.");
    }

    // =========================================================
    // GET ALL DESIGNATIONS
    // GET: api/Designation
    // Admin + HR
    // =========================================================

    [HttpGet]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetAllDesignations()
    {
        List<DesignationListDto> designations =
            await _designationService.GetAllDesignationsAsync();

        return Ok(designations);
    }

    // =========================================================
    // GET DESIGNATION BY ID
    // GET: api/Designation/{id}
    // Admin + HR
    // =========================================================

    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetDesignationById(
        int id)
    {
        if (id <= 0)
        {
            return BadRequest(
                "Designation ID must be greater than zero.");
        }

        DesignationDetailsDto? designation =
            await _designationService.GetDesignationByIdAsync(id);

        if (designation == null)
        {
            return NotFound(
                "Designation not found.");
        }

        return Ok(designation);
    }

    // =========================================================
    // UPDATE DESIGNATION
    // PUT: api/Designation/{id}
    // Admin only
    // =========================================================

    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateDesignation(
        int id,
        UpdateDesignationDto dto)
    {
        if (id <= 0)
        {
            return BadRequest(
                "Designation ID must be greater than zero.");
        }

        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        bool result =
            await _designationService.UpdateDesignationAsync(id, dto);

        if (!result)
        {
            DesignationDetailsDto? existingDesignation =
                await _designationService.GetDesignationByIdAsync(id);

            if (existingDesignation == null)
            {
                return NotFound(
                    "Designation not found.");
            }

            return Conflict(
                "Designation name already exists or could not be updated.");
        }

        return Ok(
            "Designation updated successfully.");
    }

    // =========================================================
    // DELETE DESIGNATION
    // DELETE: api/Designation/{id}
    // Admin only
    // =========================================================

    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteDesignation(
        int id)
    {
        if (id <= 0)
        {
            return BadRequest(
                "Designation ID must be greater than zero.");
        }

        bool result =
            await _designationService.DeleteDesignationAsync(id);

        if (!result)
        {
            DesignationDetailsDto? existingDesignation =
                await _designationService
                    .GetDesignationByIdAsync(id);

            if (existingDesignation == null)
            {
                return NotFound(
                    "Designation not found.");
            }

            return Conflict(
                "Designation cannot be deleted because employees are assigned to it.");
        }

        return Ok(
            "Designation deleted successfully.");
    }

    // =========================================================
    // UPDATE DESIGNATION STATUS
    // PUT: api/Designation/{id}/status
    // Admin only
    // =========================================================

    [HttpPut("{id:int}/status")]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateDesignationStatus(
        int id,
        UpdateDesignationStatusDto dto)
    {
        if (id <= 0)
        {
            return BadRequest(
                "Designation ID must be greater than zero.");
        }

        if (!ModelState.IsValid)
        {
            return ValidationProblem(ModelState);
        }

        bool result =
            await _designationService
                .UpdateDesignationStatusAsync(id, dto);

        if (!result)
        {
            return NotFound(
                "Designation not found.");
        }

        return Ok(
            "Designation status updated successfully.");
    }

    // =========================================================
    // GET EMPLOYEES BY DESIGNATION
    // GET: api/Designation/{id}/employees
    // Admin + HR
    // =========================================================

    [HttpGet("{id:int}/employees")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetEmployeesByDesignation(
        int id)
    {
        if (id <= 0)
        {
            return BadRequest(
                "Designation ID must be greater than zero.");
        }

        DesignationDetailsDto? designation =
            await _designationService
                .GetDesignationByIdAsync(id);

        if (designation == null)
        {
            return NotFound(
                "Designation not found.");
        }

        List<DesignationEmployeeDto> employees =
            await _designationService
                .GetEmployeesByDesignationAsync(id);

        return Ok(employees);
    }
}