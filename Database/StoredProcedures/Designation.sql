USE EmpManagement2DB;
GO

CREATE OR ALTER PROCEDURE CreateDesignation
    @Name NVARCHAR(200),
    @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Name = LTRIM(RTRIM(@Name));

    IF EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE LOWER(Name) = LOWER(@Name)
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    INSERT INTO Designations
    (
        Name,
        Description,
        IsActive
    )
    VALUES
    (
        @Name,
        ISNULL(@Description, ''),
        1
    );

    SELECT 1 AS Result;
END;
GO





CREATE OR ALTER PROCEDURE GetAllDesignations
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Id,
        d.Name,
        d.Description,
        d.IsActive,
        COUNT
        (
            CASE
                WHEN e.IsActive = 1 THEN 1
            END
        ) AS EmployeeCount
    FROM Designations d
    LEFT JOIN EmployeeDesignations ed
        ON ed.DesignationId = d.Id
    LEFT JOIN Employees e
        ON e.Id = ed.EmployeeId
    GROUP BY
        d.Id,
        d.Name,
        d.Description,
        d.IsActive
    ORDER BY d.Name;
END;
GO





CREATE OR ALTER PROCEDURE GetDesignationById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        d.Id,
        d.Name,
        d.Description,
        d.IsActive,
        COUNT
        (
            CASE
                WHEN e.IsActive = 1 THEN 1
            END
        ) AS EmployeeCount
    FROM Designations d
    LEFT JOIN EmployeeDesignations ed
        ON ed.DesignationId = d.Id
    LEFT JOIN Employees e
        ON e.Id = ed.EmployeeId
    WHERE d.Id = @Id
    GROUP BY
        d.Id,
        d.Name,
        d.Description,
        d.IsActive;
END;
GO





CREATE OR ALTER PROCEDURE UpdateDesignation
    @Id INT,
    @Name NVARCHAR(200),
    @Description NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Name = LTRIM(RTRIM(@Name));

    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id <> @Id
          AND LOWER(Name) = LOWER(@Name)
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE Designations
    SET
        Name = @Name,
        Description = ISNULL(@Description, '')
    WHERE Id = @Id;

    SELECT 1 AS Result;
END;
GO






CREATE OR ALTER PROCEDURE DeleteDesignation
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM EmployeeDesignations
        WHERE DesignationId = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    DELETE FROM Designations
    WHERE Id = @Id;

    SELECT 1 AS Result;
END;
GO




CREATE OR ALTER PROCEDURE UpdateDesignationStatus
    @Id INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE Designations
    SET IsActive = @IsActive
    WHERE Id = @Id;

    SELECT 1 AS Result;
END;
GO



CREATE OR ALTER PROCEDURE GetEmployeesByDesignation
    @DesignationId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        e.DepartmentId,
        e.TeamId,
        e.IsActive
    FROM EmployeeDesignations ed
    INNER JOIN Employees e
        ON e.Id = ed.EmployeeId
    WHERE ed.DesignationId = @DesignationId
    ORDER BY e.Name;
END;
GO