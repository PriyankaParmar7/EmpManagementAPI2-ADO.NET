

-- 1. Create Department
CREATE OR ALTER PROCEDURE CreateDepartment
    @Name NVARCHAR(100),
    @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM Departments
        WHERE Name = @Name
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    INSERT INTO Departments
    (
        Name,
        Description,
        IsActive
    )
    VALUES
    (
        @Name,
        @Description,
        1
    );

    SELECT 1 AS Result;
END
GO


-- 2. Get All Departments
CREATE OR ALTER PROCEDURE GetAllDepartments
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Id,
        d.Name,
        d.Description,
        COUNT(DISTINCT e.Id) AS TotalEmployees,
        COUNT(DISTINCT t.Id) AS TotalTeams,
        d.IsActive
    FROM Departments d
    LEFT JOIN Employees e
        ON e.DepartmentId = d.Id
    LEFT JOIN Teams t
        ON t.DepartmentId = d.Id
    GROUP BY
        d.Id,
        d.Name,
        d.Description,
        d.IsActive
    ORDER BY d.Id;
END
GO


-- 3. Get Department By Id
CREATE OR ALTER PROCEDURE GetDepartmentById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Id,
        d.Name,
        d.Description,
        COUNT(DISTINCT e.Id) AS TotalEmployees,
        COUNT(DISTINCT t.Id) AS TotalTeams,
        d.IsActive
    FROM Departments d
    LEFT JOIN Employees e
        ON e.DepartmentId = d.Id
    LEFT JOIN Teams t
        ON t.DepartmentId = d.Id
    WHERE d.Id = @Id
    GROUP BY
        d.Id,
        d.Name,
        d.Description,
        d.IsActive;
END
GO

-- 4. Get Department Count
CREATE OR ALTER PROCEDURE GetDepartmentCount
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*)
    FROM Departments;
END
GO

-- 5. Get Teams By Department
CREATE OR ALTER PROCEDURE GetTeamsByDepartment
    @DepartmentId INT
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
    WHERE t.DepartmentId = @DepartmentId
    GROUP BY
        t.Id,
        t.Name,
        th.Name,
        t.IsActive
    ORDER BY t.Id;
END
GO

-- 6. Get Employees By Department
CREATE OR ALTER PROCEDURE GetEmployeesByDepartment
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(dg.Name, '') AS Designation,
        ISNULL(t.Name, '') AS Team,
        e.IsActive
    FROM Employees e
    LEFT JOIN Teams t
        ON t.Id = e.TeamId
    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id
    LEFT JOIN Designations dg
        ON dg.Id = ed.DesignationId
    WHERE e.DepartmentId = @DepartmentId
    ORDER BY e.Id;
END
GO


EXEC GetAllDepartments;

EXEC GetDepartmentById @Id = 1;
EXEC GetDepartmentCount;
EXEC GetTeamsByDepartment @DepartmentId = 1;
EXEC GetEmployeesByDepartment @DepartmentId = 1;