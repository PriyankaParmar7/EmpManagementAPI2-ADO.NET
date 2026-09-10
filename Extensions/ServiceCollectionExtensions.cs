using EmpManagementAPI2.Interfaces;
using EmpManagementAPI2.Repository;
using EmpManagementAPI2.Services;
using EmpManagementAPI2.Database;

namespace EmpManagementAPI2.Extensions;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddApplicationServices(
        this IServiceCollection services)
    {
        services.AddScoped<IDbConnectionFactory, DbConnectionFactory>();
        services.AddScoped<ISetupService, SetupService>();

        services.AddSingleton<IDatabaseInitializer, DatabaseInitializer>();

        services.AddScoped<IPasswordService, PasswordService>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IEmailService, EmailService>();

        services.AddScoped<IEmployeeRepository, EmployeeRepository>();
        services.AddScoped<IEmployeeService, EmployeeService>();

        services.AddScoped<IDepartmentRepository, DepartmentRepository>();
        services.AddScoped<IDepartmentService, DepartmentService>();

        services.AddScoped<ITeamRepository, TeamRepository>();
        services.AddScoped<ITeamService, TeamService>();

        services.AddScoped<IDesignationRepository, DesignationRepository>();
        services.AddScoped<IDesignationService, DesignationService>();

        services.AddScoped<ILeaveRepository, LeaveRepository>();
        services.AddScoped<ILeaveService, LeaveService>();

        return services;
    }
}