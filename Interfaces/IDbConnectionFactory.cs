using Microsoft.Data.SqlClient;

namespace EmpManagementAPI2.Interfaces;

public interface IDbConnectionFactory
{
    SqlConnection CreateConnection();
}