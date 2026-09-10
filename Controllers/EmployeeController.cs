using EmpManagementAPI2.DTOs.Employee;
using EmpManagementAPI2.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EmpManagementAPI2.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EmployeeController : ControllerBase
{
    private readonly IEmployeeService _employeeService;

    public EmployeeController(IEmployeeService employeeService)
    {
        _employeeService = employeeService;
    }


    // CREATE EMPLOYEE
    // Admin + HR
    [HttpPost]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> CreateEmployee(CreateEmployeeDto dto)
    {
        bool result = await _employeeService.CreateEmployeeAsync(dto);

        if (!result)
        {
            return BadRequest("Employee could not be created.");
        }

        return Ok("Employee created successfully.");
    }


    // GET ALL EMPLOYEES
    // Admin + HR
    // SEARCH / FILTER / PAGINATION EMPLOYEES

    [HttpPost("search")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> SearchEmployees(
        [FromBody] EmployeeFilterDto filter)
    {
        EmployeePagedResultDto employees =
            await _employeeService.GetAllEmployeesAsync(filter);

        return Ok(employees);
    }


    // GET EMPLOYEE BY ID
    // Admin + HR
    [HttpGet("{id:int}")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetEmployeeById(int id)
    {
        EmployeeListDto? employee =
            await _employeeService.GetEmployeeByIdAsync(id);

        if (employee == null)
        {
            return NotFound("Employee not found.");
        }

        return Ok(employee);
    }


    // UPDATE EMPLOYEE
    // Admin + HR
    [HttpPut("{id:int}")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployee(
        int id,
        UpdateEmployeeDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeAsync(id, dto);

        if (!result)
        {
            return BadRequest("Employee could not be updated.");
        }

        return Ok("Employee updated successfully.");
    }


    // DELETE EMPLOYEE
    // Admin + HR
    [HttpDelete("{id:int}")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> DeleteEmployee(int id)
    {
        bool result =
            await _employeeService.DeleteEmployeeAsync(id);

        if (!result)
        {
            return NotFound("Employee not found.");
        }

        return Ok("Employee deleted successfully.");
    }


    // GET EMPLOYEE COUNT
    // Admin + HR
    [HttpGet("count")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetEmployeeCount()
    {
        int count =
            await _employeeService.GetEmployeeCountAsync();

        return Ok(new
        {
            totalEmployees = count
        });
    }


    // UPDATE EMPLOYEE STATUS
    // Admin + HR
    [HttpPut("{id:int}/status")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployeeStatus(
        int id,
        UpdateEmployeeStatusDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeStatusAsync(id, dto);

        if (!result)
        {
            return NotFound("Employee not found.");
        }

        return Ok("Employee status updated successfully.");
    }


    // GET MY PROFILE
    // Employee can see own profile
    [HttpGet("me")]
    [Authorize(Roles = "Employee,HR,Admin")]
    public async Task<IActionResult> GetMyProfile()
    {
        Claim? userIdClaim =
            User.FindFirst(ClaimTypes.NameIdentifier);

        if (userIdClaim == null)
        {
            return Unauthorized();
        }

        int userId = int.Parse(userIdClaim.Value);

        EmployeeListDto? employee =
            await _employeeService.GetMyProfileAsync(userId);

        if (employee == null)
        {
            return NotFound("Employee profile not found.");
        }

        return Ok(employee);
    }


    // UPDATE MY PROFILE
    // Employee can edit own basic profile
    [HttpPut("me")]
    [Authorize(Roles = "Employee,HR,Admin")]
    public async Task<IActionResult> UpdateMyProfile(
        UpdateMyProfileDto dto)
    {
        Claim? userIdClaim =
            User.FindFirst(ClaimTypes.NameIdentifier);

        if (userIdClaim == null)
        {
            return Unauthorized();
        }

        int userId = int.Parse(userIdClaim.Value);

        bool result =
            await _employeeService.UpdateMyProfileAsync(userId, dto);

        if (!result)
        {
            return BadRequest("Profile could not be updated.");
        }

        return Ok("Profile updated successfully.");
    }


    // UPDATE EMPLOYEE DEPARTMENT
    // Admin + HR
    [HttpPut("{id:int}/department")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployeeDepartment(
        int id,
        UpdateEmployeeDepartmentDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeDepartmentAsync(id, dto);

        if (!result)
        {
            return BadRequest(
                "Employee or department is invalid.");
        }

        return Ok("Employee department updated successfully.");
    }


    // UPDATE EMPLOYEE TEAM
    // Admin + HR
    [HttpPut("{id:int}/team")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployeeTeam(
        int id,
        UpdateEmployeeTeamDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeTeamAsync(id, dto);

        if (!result)
        {
            return BadRequest(
                "Employee or team is invalid, or team does not belong to the employee's department.");
        }

        return Ok("Employee team updated successfully.");
    }


    // UPDATE EMPLOYEE SUPERVISOR
    // Admin + HR
    [HttpPut("{id:int}/supervisor")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployeeSupervisor(
        int id,
        UpdateEmployeeSupervisorDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeSupervisorAsync(id, dto);

        if (!result)
        {
            return BadRequest(
                "Employee or supervisor is invalid.");
        }

        return Ok("Employee supervisor updated successfully.");
    }


    // UPDATE EMPLOYEE DESIGNATION
    // Admin + HR
    [HttpPut("{id:int}/designation")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> UpdateEmployeeDesignation(
        int id,
        UpdateEmployeeDesignationDto dto)
    {
        bool result =
            await _employeeService.UpdateEmployeeDesignationAsync(id, dto);

        if (!result)
        {
            return BadRequest(
                "Employee or designation is invalid.");
        }

        return Ok("Employee designation updated successfully.");
    }


    // GET EMPLOYEE SUBORDINATES
    [HttpGet("{id:int}/subordinates")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetSubordinates(int id)
    {
        EmployeeListDto? employee =
            await _employeeService.GetEmployeeByIdAsync(id);

        if (employee == null)
        {
            return NotFound("Employee not found.");
        }

        List<EmployeeSubordinateDto> subordinates =
            await _employeeService.GetSubordinatesAsync(id);

        return Ok(new
        {
            supervisorId = id,
            supervisorName = employee.Name,
            totalSubordinates = subordinates.Count,
            employees = subordinates
        });
    }


    // GET EMPLOYEE'S SUPERVISOR
    [HttpGet("{id:int}/supervisor")]
    [Authorize(Roles = "Admin,HR")]
    public async Task<IActionResult> GetSupervisor(int id)
    {
        EmployeeListDto? employee =
            await _employeeService.GetEmployeeByIdAsync(id);

        if (employee == null)
        {
            return NotFound("Employee not found.");
        }

        EmployeeSupervisorDto? supervisor =
            await _employeeService.GetSupervisorAsync(id);

        if (supervisor == null)
        {
            return NotFound("This employee has no supervisor.");
        }

        return Ok(new
        {
            employeeId = id,
            employeeName = employee.Name,
            supervisor
        });
    }
}