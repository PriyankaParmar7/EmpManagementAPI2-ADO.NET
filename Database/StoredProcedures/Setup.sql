USE EmpManagement2DB;
GO

CREATE OR ALTER PROCEDURE CreateInitialAdmin
    @Username NVARCHAR(100),
    @Email NVARCHAR(255),
    @PasswordHash VARBINARY(MAX),
    @PasswordSalt VARBINARY(MAX),
    @Name NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY

        DECLARE @AdminRoleId INT;

        -- Find Admin role
        SELECT @AdminRoleId = Id
        FROM Roles
        WHERE Name = 'Admin';

        -- Admin role must exist
        IF @AdminRoleId IS NULL
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 0 AS Result;
            RETURN;
        END;

        -- Check whether Admin already exists
        IF EXISTS
        (
            SELECT 1
            FROM UserRoles
            WHERE RoleId = @AdminRoleId
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 0 AS Result;
            RETURN;
        END;

        -- Check username
        IF EXISTS
        (
            SELECT 1
            FROM AppUsers
            WHERE Username = @Username
        )
        BEGIN
            ROLLBACK TRANSACTION;
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
            ROLLBACK TRANSACTION;
            SELECT 0 AS Result;
            RETURN;
        END;

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
            NULL,
            NULL,
            NULL,
            GETUTCDATE(),
            1
        );

        -- Assign Admin role
        INSERT INTO UserRoles
        (
            UserId,
            RoleId
        )
        VALUES
        (
            @UserId,
            @AdminRoleId
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