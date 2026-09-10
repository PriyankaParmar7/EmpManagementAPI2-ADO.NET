USE EmpManagement2DB;
GO

CREATE OR ALTER PROCEDURE CreateTeam
    @Name NVARCHAR(100),
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Name = LTRIM(RTRIM(@Name));

    IF @Name = N''
       OR NOT EXISTS
       (
           SELECT 1
           FROM Departments
           WHERE Id = @DepartmentId
       )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Teams
        WHERE Name = @Name
          AND DepartmentId = @DepartmentId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    INSERT INTO Teams
    (
        Name,
        DepartmentId,
        IsActive
    )
    VALUES
    (
        @Name,
        @DepartmentId,
        1
    );

    SELECT 1 AS Result;
END;
GO

CREATE OR ALTER PROCEDURE GetAllTeams
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Id,
        t.Name,
        COUNT(e.Id) AS EmployeeCount,
        ISNULL(th.Name, '') AS TeamHead,
        t.IsActive
    FROM Teams t
    LEFT JOIN Employees e
        ON e.TeamId = t.Id
    LEFT JOIN Employees th
        ON th.Id = t.TeamHeadEmployeeId
    GROUP BY
        t.Id,
        t.Name,
        th.Name,
        t.IsActive
    ORDER BY t.Id;
END;
GO

CREATE OR ALTER PROCEDURE GetTeamById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        t.Id,
        t.Name,
        t.DepartmentId,
        d.Name AS Department,
        t.TeamHeadEmployeeId,
        ISNULL(th.Name, '') AS TeamHead,
        COUNT(e.Id) AS EmployeeCount,
        t.IsActive
    FROM Teams t
    INNER JOIN Departments d
        ON d.Id = t.DepartmentId
    LEFT JOIN Employees th
        ON th.Id = t.TeamHeadEmployeeId
    LEFT JOIN Employees e
        ON e.TeamId = t.Id
    WHERE t.Id = @Id
    GROUP BY
        t.Id,
        t.Name,
        t.DepartmentId,
        d.Name,
        t.TeamHeadEmployeeId,
        th.Name,
        t.IsActive;
END;
GO

CREATE OR ALTER PROCEDURE GetEmployeesByTeam
    @TeamId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(dg.Name, '') AS Designation,
        e.IsActive
    FROM Employees e
    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id
    LEFT JOIN Designations dg
        ON dg.Id = ed.DesignationId
    WHERE e.TeamId = @TeamId
    ORDER BY e.Name;
END;
GO

CREATE OR ALTER PROCEDURE GetTeamCount
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*)
    FROM Teams;
END;
GO
