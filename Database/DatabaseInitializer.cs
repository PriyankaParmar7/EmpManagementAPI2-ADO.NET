using System.Reflection;
using System.Text.RegularExpressions;
using Microsoft.Data.SqlClient;

namespace EmpManagementAPI2.Database;

public interface IDatabaseInitializer
{
    Task InitializeAsync(CancellationToken cancellationToken = default);
}

public sealed class DatabaseInitializer : IDatabaseInitializer
{
    private const string DatabaseName = "EmpManagement2DB";
    private readonly IConfiguration _configuration;
    private readonly ILogger<DatabaseInitializer> _logger;

    public DatabaseInitializer(
        IConfiguration configuration,
        ILogger<DatabaseInitializer> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    public async Task InitializeAsync(CancellationToken cancellationToken = default)
    {
        string connectionString =
            _configuration.GetConnectionString("DefaultConnection")
            ?? throw new InvalidOperationException(
                "DefaultConnection is not configured.");

        SqlConnectionStringBuilder builder =
            new SqlConnectionStringBuilder(connectionString)
            {
                InitialCatalog = "master"
            };

        await using SqlConnection connection =
            new SqlConnection(builder.ConnectionString);

        await connection.OpenAsync(cancellationToken);

        string script = await ReadSetupScriptAsync(cancellationToken);
        string[] batches = Regex.Split(
                script,
                @"^\s*GO\s*;?\s*$",
                RegexOptions.Multiline | RegexOptions.IgnoreCase)
            .Where(batch => !string.IsNullOrWhiteSpace(batch))
            .ToArray();

        foreach (string batch in batches)
        {
            await using SqlCommand command =
                new SqlCommand(batch, connection);

            await command.ExecuteNonQueryAsync(cancellationToken);
        }

        _logger.LogInformation(
            "Database initialization completed for {DatabaseName}.",
            DatabaseName);
    }

    private static async Task<string> ReadSetupScriptAsync(
        CancellationToken cancellationToken)
    {
        Assembly assembly = typeof(DatabaseInitializer).Assembly;
        const string resourceName =
            "EmpManagementAPI2.Database.DatabaseSetup.sql";

        await using Stream? stream =
            assembly.GetManifestResourceStream(resourceName);

        if (stream == null)
        {
            throw new InvalidOperationException(
                $"Embedded database setup script was not found: {resourceName}");
        }

        using StreamReader reader = new StreamReader(stream);
        return await reader.ReadToEndAsync(cancellationToken);
    }
}
