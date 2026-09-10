USE EmpManagement2DB;
GO

CREATE OR ALTER PROCEDURE CreateEmployee
    @Username NVARCHAR(100),
    @Email NVARCHAR(200),
    @PasswordHash VARBINARY(MAX),
    @PasswordSalt VARBINARY(MAX),
    @Name NVARCHAR(200),
    @DepartmentId INT = NULL,
    @TeamId INT = NULL,
    @SupervisorId INT = NULL,
    @DesignationId INT,
    @RoleId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check username
    IF EXISTS
    (
        SELECT 1
        FROM AppUsers
        WHERE Username = @Username
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check email
    IF EXISTS
    (
        SELECT 1
        FROM AppUsers
        WHERE Email = @Email
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check role
    IF NOT EXISTS
    (
        SELECT 1
        FROM Roles
        WHERE Id = @RoleId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check designation
    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @DesignationId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check department if supplied
    IF @DepartmentId IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM Departments
           WHERE Id = @DepartmentId
       )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check team if supplied
    IF @TeamId IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM Teams
            WHERE Id = @TeamId
        )
        BEGIN
            SELECT 0 AS Result;
            RETURN;
        END;

        -- Team must belong to selected department
        IF @DepartmentId IS NOT NULL
           AND EXISTS
           (
               SELECT 1
               FROM Teams
               WHERE Id = @TeamId
                 AND DepartmentId <> @DepartmentId
           )
        BEGIN
            SELECT 0 AS Result;
            RETURN;
        END;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Create AppUser
        INSERT INTO AppUsers
        (
            Username,
            Email,
            PasswordHash,
            PasswordSalt,
            IsActive
        )
        VALUES
        (
            @Username,
            @Email,
            @PasswordHash,
            @PasswordSalt,
            1
        );

        DECLARE @UserId INT = SCOPE_IDENTITY();

        -- Create Employee
        INSERT INTO Employees
        (
            AppUserId,
            Name,
            Email,
            DepartmentId,
            TeamId,
            SupervisorId,
            JoiningDate,
            IsActive
        )
        VALUES
        (
            @UserId,
            @Name,
            @Email,
            @DepartmentId,
            @TeamId,
            @SupervisorId,
            GETUTCDATE(),
            1
        );

        DECLARE @EmployeeId INT = SCOPE_IDENTITY();

        -- Assign designation
        INSERT INTO EmployeeDesignations
        (
            EmployeeId,
            DesignationId
        )
        VALUES
        (
            @EmployeeId,
            @DesignationId
        );

        -- Assign role
        INSERT INTO UserRoles
        (
            UserId,
            RoleId
        )
        VALUES
        (
            @UserId,
            @RoleId
        );

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY

    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO





CREATE OR ALTER PROCEDURE GetAllEmployees
    @Page INT = 1,
    @PageSize INT = 20,
    @Search NVARCHAR(200) = NULL,
    @Status NVARCHAR(50) = NULL,
    @DepartmentId INT = NULL,
    @TeamId INT = NULL,
    @DesignationId INT = NULL,
    @SupervisorId INT = NULL,
    @SortBy NVARCHAR(50) = 'name',
    @SortDescending BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- Prevent invalid pagination values
    IF @Page < 1
        SET @Page = 1;

    IF @PageSize < 1
        SET @PageSize = 20;

    DECLARE @Offset INT;

    SET @Offset = (@Page - 1) * @PageSize;

    -- Total records
    SELECT COUNT(DISTINCT e.Id) AS TotalRecords
    FROM Employees e
    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id
    WHERE
        (
            @Search IS NULL
            OR e.Name LIKE '%' + @Search + '%'
            OR e.Email LIKE '%' + @Search + '%'
        )
        AND
        (
            @Status IS NULL
            OR
            (
                @Status = 'Active'
                AND e.IsActive = 1
            )
            OR
            (
                @Status = 'Inactive'
                AND e.IsActive = 0
            )
        )
        AND
        (
            @DepartmentId IS NULL
            OR e.DepartmentId = @DepartmentId
        )
        AND
        (
            @TeamId IS NULL
            OR e.TeamId = @TeamId
        )
        AND
        (
            @DesignationId IS NULL
            OR ed.DesignationId = @DesignationId
        )
        AND
        (
            @SupervisorId IS NULL
            OR e.SupervisorId = @SupervisorId
        );

    -- Employee records
    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(d.Name, '') AS Department,
        ISNULL(t.Name, '') AS Team,
        ISNULL(des.Name, '') AS Designation,
        ISNULL(s.Name, '') AS Supervisor,
        e.IsActive
    FROM Employees e

    LEFT JOIN Departments d
        ON d.Id = e.DepartmentId

    LEFT JOIN Teams t
        ON t.Id = e.TeamId

    LEFT JOIN Employees s
        ON s.Id = e.SupervisorId

    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id

    LEFT JOIN Designations des
        ON des.Id = ed.DesignationId

    WHERE
        (
            @Search IS NULL
            OR e.Name LIKE '%' + @Search + '%'
            OR e.Email LIKE '%' + @Search + '%'
        )
        AND
        (
            @Status IS NULL
            OR
            (
                @Status = 'Active'
                AND e.IsActive = 1
            )
            OR
            (
                @Status = 'Inactive'
                AND e.IsActive = 0
            )
        )
        AND
        (
            @DepartmentId IS NULL
            OR e.DepartmentId = @DepartmentId
        )
        AND
        (
            @TeamId IS NULL
            OR e.TeamId = @TeamId
        )
        AND
        (
            @DesignationId IS NULL
            OR ed.DesignationId = @DesignationId
        )
        AND
        (
            @SupervisorId IS NULL
            OR e.SupervisorId = @SupervisorId
        )

    ORDER BY
        CASE
            WHEN @SortBy = 'name'
                 AND @SortDescending = 0
            THEN e.Name
        END ASC,

        CASE
            WHEN @SortBy = 'name'
                 AND @SortDescending = 1
            THEN e.Name
        END DESC,

        CASE
            WHEN @SortBy = 'email'
                 AND @SortDescending = 0
            THEN e.Email
        END ASC,

        CASE
            WHEN @SortBy = 'email'
                 AND @SortDescending = 1
            THEN e.Email
        END DESC,

        CASE
            WHEN @SortBy = 'id'
                 AND @SortDescending = 0
            THEN e.Id
        END ASC,

        CASE
            WHEN @SortBy = 'id'
                 AND @SortDescending = 1
            THEN e.Id
        END DESC,

        e.Id

    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO



CREATE OR ALTER PROCEDURE GetEmployeeById
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(d.Name, '') AS Department,
        ISNULL(t.Name, '') AS Team,
        ISNULL(des.Name, '') AS Designation,
        ISNULL(s.Name, '') AS Supervisor,
        e.IsActive
    FROM Employees e

    LEFT JOIN Departments d
        ON d.Id = e.DepartmentId

    LEFT JOIN Teams t
        ON t.Id = e.TeamId

    LEFT JOIN Employees s
        ON s.Id = e.SupervisorId

    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id

    LEFT JOIN Designations des
        ON des.Id = ed.DesignationId

    WHERE e.Id = @Id;
END;
GO





CREATE OR ALTER PROCEDURE UpdateEmployee
    @Id INT,
    @Name NVARCHAR(200),
    @Email NVARCHAR(200),
    @DepartmentId INT = NULL,
    @TeamId INT = NULL,
    @SupervisorId INT = NULL,
    @DesignationId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Get AppUserId
    DECLARE @AppUserId INT;

    SELECT @AppUserId = AppUserId
    FROM Employees
    WHERE Id = @Id;

    -- Check duplicate email
    IF EXISTS
    (
        SELECT 1
        FROM AppUsers
        WHERE Email = @Email
          AND Id <> @AppUserId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Validate Department
    IF @DepartmentId IS NOT NULL
       AND NOT EXISTS
       (
           SELECT 1
           FROM Departments
           WHERE Id = @DepartmentId
       )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Validate Team
    IF @TeamId IS NOT NULL
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM Teams
            WHERE Id = @TeamId
        )
        BEGIN
            SELECT 0 AS Result;
            RETURN;
        END;

        -- Team must belong to selected department
        IF @DepartmentId IS NOT NULL
           AND EXISTS
           (
               SELECT 1
               FROM Teams
               WHERE Id = @TeamId
                 AND DepartmentId <> @DepartmentId
           )
        BEGIN
            SELECT 0 AS Result;
            RETURN;
        END;
    END;

    -- Validate Designation
    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @DesignationId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Update Employee
        UPDATE Employees
        SET
            Name = @Name,
            Email = @Email,
            DepartmentId = @DepartmentId,
            TeamId = @TeamId,
            SupervisorId = @SupervisorId
        WHERE Id = @Id;

        -- Update AppUser email
        UPDATE AppUsers
        SET Email = @Email
        WHERE Id = @AppUserId;

        -- Update Designation
        UPDATE EmployeeDesignations
        SET DesignationId = @DesignationId
        WHERE EmployeeId = @Id;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO




CREATE OR ALTER PROCEDURE DeleteEmployee
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    DECLARE @AppUserId INT;

    SELECT @AppUserId = AppUserId
    FROM Employees
    WHERE Id = @Id;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Delete employee designation
        DELETE FROM EmployeeDesignations
        WHERE EmployeeId = @Id;

        -- Delete employee
        DELETE FROM Employees
        WHERE Id = @Id;

        -- Delete application user
        DELETE FROM AppUsers
        WHERE Id = @AppUserId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO




CREATE OR ALTER PROCEDURE GetEmployeeCount
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*)
    FROM Employees
    WHERE IsActive = 1;
END;
GO



CREATE OR ALTER PROCEDURE UpdateEmployeeStatus
    @Id INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    DECLARE @AppUserId INT;

    SELECT @AppUserId = AppUserId
    FROM Employees
    WHERE Id = @Id;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Update employee status
        UPDATE Employees
        SET IsActive = @IsActive
        WHERE Id = @Id;

        -- Update login/user status
        UPDATE AppUsers
        SET IsActive = @IsActive
        WHERE Id = @AppUserId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO

CREATE OR ALTER PROCEDURE GetMyProfile
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(d.Name, '') AS Department,
        ISNULL(t.Name, '') AS Team,
        ISNULL(des.Name, '') AS Designation,
        ISNULL(s.Name, '') AS Supervisor,
        e.IsActive
    FROM Employees e

    LEFT JOIN Departments d
        ON d.Id = e.DepartmentId

    LEFT JOIN Teams t
        ON t.Id = e.TeamId

    LEFT JOIN Employees s
        ON s.Id = e.SupervisorId

    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id

    LEFT JOIN Designations des
        ON des.Id = ed.DesignationId

    WHERE e.AppUserId = @UserId;
END;
GO





CREATE OR ALTER PROCEDURE UpdateMyProfile
    @UserId INT,
    @Name NVARCHAR(200),
    @Email NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE AppUserId = @UserId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check duplicate email
    IF EXISTS
    (
        SELECT 1
        FROM AppUsers
        WHERE Email = @Email
          AND Id <> @UserId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        -- Update employee profile
        UPDATE Employees
        SET
            Name = @Name,
            Email = @Email
        WHERE AppUserId = @UserId;

        -- Update login user's email
        UPDATE AppUsers
        SET Email = @Email
        WHERE Id = @UserId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO





CREATE OR ALTER PROCEDURE UpdateEmployeeDepartment
    @Id INT,
    @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check department exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Departments
        WHERE Id = @DepartmentId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- If employee has a team,
    -- make sure the team belongs to the new department
    IF EXISTS
    (
        SELECT 1
        FROM Employees e
        INNER JOIN Teams t
            ON t.Id = e.TeamId
        WHERE e.Id = @Id
          AND t.DepartmentId <> @DepartmentId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE Employees
        SET DepartmentId = @DepartmentId
        WHERE Id = @Id;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO



CREATE OR ALTER PROCEDURE UpdateEmployeeTeam
    @Id INT,
    @TeamId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check team exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Teams
        WHERE Id = @TeamId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check that the team belongs to
    -- the employee's current department
    IF EXISTS
    (
        SELECT 1
        FROM Employees e
        INNER JOIN Teams t
            ON t.Id = @TeamId
        WHERE e.Id = @Id
          AND e.DepartmentId IS NOT NULL
          AND t.DepartmentId <> e.DepartmentId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE Employees
        SET TeamId = @TeamId
        WHERE Id = @Id;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO






CREATE OR ALTER PROCEDURE UpdateEmployeeSupervisor
    @Id INT,
    @SupervisorId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check supervisor exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @SupervisorId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Employee cannot be their own supervisor
    IF @Id = @SupervisorId
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE Employees
        SET SupervisorId = @SupervisorId
        WHERE Id = @Id;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO





CREATE OR ALTER PROCEDURE UpdateEmployeeDesignation
    @Id INT,
    @DesignationId INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Check employee exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Employees
        WHERE Id = @Id
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    -- Check designation exists
    IF NOT EXISTS
    (
        SELECT 1
        FROM Designations
        WHERE Id = @DesignationId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    BEGIN TRANSACTION;

    BEGIN TRY

        UPDATE EmployeeDesignations
        SET DesignationId = @DesignationId
        WHERE EmployeeId = @Id;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION;

        SELECT 0 AS Result;

    END CATCH;
END;
GO





CREATE OR ALTER PROCEDURE GetSubordinates
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        e.Id,
        e.Name,
        e.Email,
        ISNULL(d.Name, '') AS Department,
        ISNULL(t.Name, '') AS Team,
        ISNULL(des.Name, '') AS Designation,
        e.IsActive
    FROM Employees e
    LEFT JOIN Departments d
        ON d.Id = e.DepartmentId
    LEFT JOIN Teams t
        ON t.Id = e.TeamId
    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = e.Id
    LEFT JOIN Designations des
        ON des.Id = ed.DesignationId
    WHERE e.SupervisorId = @EmployeeId
    ORDER BY e.Name;
END;
GO





CREATE OR ALTER PROCEDURE GetSupervisor
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.Id,
        s.Name,
        s.Email,
        ISNULL(d.Name, '') AS Department,
        ISNULL(t.Name, '') AS Team,
        ISNULL(des.Name, '') AS Designation,
        s.IsActive
    FROM Employees e
    INNER JOIN Employees s
        ON s.Id = e.SupervisorId
    LEFT JOIN Departments d
        ON d.Id = s.DepartmentId
    LEFT JOIN Teams t
        ON t.Id = s.TeamId
    LEFT JOIN EmployeeDesignations ed
        ON ed.EmployeeId = s.Id
    LEFT JOIN Designations des
        ON des.Id = ed.DesignationId
    WHERE e.Id = @EmployeeId;
END;
GO