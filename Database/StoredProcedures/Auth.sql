USE EmpManagement2DB;
GO

CREATE OR ALTER PROCEDURE LoginUser
    @Username NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        u.Id,
        u.Username,
        u.PasswordHash,
        u.PasswordSalt,
        u.IsActive,
        r.Name AS RoleName
    FROM AppUsers u
    INNER JOIN UserRoles ur
        ON ur.UserId = u.Id
    INNER JOIN Roles r
        ON r.Id = ur.RoleId
    WHERE u.Username = @Username;
END;
GO



CREATE OR ALTER PROCEDURE GetUserForPasswordChange
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        PasswordHash,
        PasswordSalt
    FROM AppUsers
    WHERE Id = @UserId;
END;
GO



CREATE OR ALTER PROCEDURE GetUserByEmail
    @Email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Id,
        Email
    FROM AppUsers
    WHERE Email = @Email;
END;
GO


CREATE OR ALTER PROCEDURE ChangeUserPassword
    @UserId INT,
    @PasswordHash VARBINARY(MAX),
    @PasswordSalt VARBINARY(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM AppUsers
        WHERE Id = @UserId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE AppUsers
    SET
        PasswordHash = @PasswordHash,
        PasswordSalt = @PasswordSalt
    WHERE Id = @UserId;

    SELECT 1 AS Result;
END;
GO



CREATE OR ALTER PROCEDURE GetHREmails
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        u.Email
    FROM UserRoles ur
    INNER JOIN Roles r
        ON r.Id = ur.RoleId
    INNER JOIN AppUsers u
        ON u.Id = ur.UserId
    WHERE r.Name = 'HR'
      AND u.IsActive = 1
      AND u.Email IS NOT NULL;
END;
GO



CREATE OR ALTER PROCEDURE GetEmployeeEmail
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        Email
    FROM Employees
    WHERE Id = @EmployeeId;
END;
GO