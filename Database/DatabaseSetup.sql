/* EmpManagement2DB database setup */

USE master;
GO
IF DB_ID(N'EmpManagement2DB') IS NULL
BEGIN
    EXEC(N'CREATE DATABASE [EmpManagement2DB]');
END;
GO
USE [EmpManagement2DB];
GO

/* TABLES */
IF OBJECT_ID(N'dbo.Roles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Roles (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Roles PRIMARY KEY, Name NVARCHAR(100) NOT NULL, Description NVARCHAR(500) NOT NULL CONSTRAINT DF_Roles_Description DEFAULT(N''));
END;
GO
IF OBJECT_ID(N'dbo.AppUsers', N'U') IS NULL
BEGIN
CREATE TABLE dbo.AppUsers (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_AppUsers PRIMARY KEY, Username NVARCHAR(100) NOT NULL, Email NVARCHAR(255) NOT NULL, PasswordHash VARBINARY(MAX) NOT NULL, PasswordSalt VARBINARY(MAX) NOT NULL, IsActive BIT NOT NULL CONSTRAINT DF_AppUsers_IsActive DEFAULT(1), CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_AppUsers_CreatedAt DEFAULT(SYSUTCDATETIME()), CONSTRAINT UQ_AppUsers_Username UNIQUE(Username), CONSTRAINT UQ_AppUsers_Email UNIQUE(Email));
END;
GO
IF OBJECT_ID(N'dbo.Departments', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Departments (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Departments PRIMARY KEY, Name NVARCHAR(100) NOT NULL, Description NVARCHAR(500) NOT NULL CONSTRAINT DF_Departments_Description DEFAULT(N''), IsActive BIT NOT NULL CONSTRAINT DF_Departments_IsActive DEFAULT(1), CONSTRAINT UQ_Departments_Name UNIQUE(Name));
END;
GO
IF OBJECT_ID(N'dbo.Designations', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Designations (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Designations PRIMARY KEY, Name NVARCHAR(200) NOT NULL, Description NVARCHAR(500) NOT NULL CONSTRAINT DF_Designations_Description DEFAULT(N''), IsActive BIT NOT NULL CONSTRAINT DF_Designations_IsActive DEFAULT(1), CONSTRAINT UQ_Designations_Name UNIQUE(Name));
END;
GO
IF OBJECT_ID(N'dbo.Employees', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Employees (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Employees PRIMARY KEY, AppUserId INT NOT NULL, Name NVARCHAR(200) NOT NULL, Email NVARCHAR(200) NOT NULL, DepartmentId INT NULL, TeamId INT NULL, SupervisorId INT NULL, JoiningDate DATETIME2 NOT NULL CONSTRAINT DF_Employees_JoiningDate DEFAULT(SYSUTCDATETIME()), IsActive BIT NOT NULL CONSTRAINT DF_Employees_IsActive DEFAULT(1), CONSTRAINT UQ_Employees_AppUserId UNIQUE(AppUserId));
END;
GO
IF OBJECT_ID(N'dbo.Teams', N'U') IS NULL
BEGIN
CREATE TABLE dbo.Teams (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Teams PRIMARY KEY, Name NVARCHAR(100) NOT NULL, DepartmentId INT NOT NULL, TeamHeadEmployeeId INT NULL, IsActive BIT NOT NULL CONSTRAINT DF_Teams_IsActive DEFAULT(1));
END;
GO
IF OBJECT_ID(N'dbo.EmployeeDesignations', N'U') IS NULL
BEGIN
CREATE TABLE dbo.EmployeeDesignations (EmployeeId INT NOT NULL, DesignationId INT NOT NULL, CONSTRAINT PK_EmployeeDesignations PRIMARY KEY(EmployeeId, DesignationId));
END;
GO
IF OBJECT_ID(N'dbo.UserRoles', N'U') IS NULL
BEGIN
CREATE TABLE dbo.UserRoles (UserId INT NOT NULL, RoleId INT NOT NULL, CONSTRAINT PK_UserRoles PRIMARY KEY(UserId, RoleId));
END;
GO
IF OBJECT_ID(N'dbo.LeaveRequests', N'U') IS NULL
BEGIN
CREATE TABLE dbo.LeaveRequests (Id INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_LeaveRequests PRIMARY KEY, EmployeeId INT NOT NULL, LeaveType NVARCHAR(100) NOT NULL, Reason NVARCHAR(1000) NOT NULL, StartDate DATETIME2 NOT NULL, EndDate DATETIME2 NOT NULL, Status NVARCHAR(50) NOT NULL CONSTRAINT DF_LeaveRequests_Status DEFAULT(N'Pending'), IsTeamLeave BIT NOT NULL CONSTRAINT DF_LeaveRequests_IsTeamLeave DEFAULT(0), TeamId INT NULL, ApprovedBy INT NULL, ApprovedDate DATETIME2 NULL, CreatedAt DATETIME2 NOT NULL CONSTRAINT DF_LeaveRequests_CreatedAt DEFAULT(SYSUTCDATETIME()));
END;
GO

/* FOREIGN KEYS */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Employees_AppUsers') ALTER TABLE dbo.Employees ADD CONSTRAINT FK_Employees_AppUsers FOREIGN KEY(AppUserId) REFERENCES dbo.AppUsers(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Employees_Departments') ALTER TABLE dbo.Employees ADD CONSTRAINT FK_Employees_Departments FOREIGN KEY(DepartmentId) REFERENCES dbo.Departments(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Employees_Teams') ALTER TABLE dbo.Employees ADD CONSTRAINT FK_Employees_Teams FOREIGN KEY(TeamId) REFERENCES dbo.Teams(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Employees_Supervisor') ALTER TABLE dbo.Employees ADD CONSTRAINT FK_Employees_Supervisor FOREIGN KEY(SupervisorId) REFERENCES dbo.Employees(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Teams_Departments') ALTER TABLE dbo.Teams ADD CONSTRAINT FK_Teams_Departments FOREIGN KEY(DepartmentId) REFERENCES dbo.Departments(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_Teams_TeamHeadEmployee') ALTER TABLE dbo.Teams ADD CONSTRAINT FK_Teams_TeamHeadEmployee FOREIGN KEY(TeamHeadEmployeeId) REFERENCES dbo.Employees(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_EmployeeDesignations_Employees') ALTER TABLE dbo.EmployeeDesignations ADD CONSTRAINT FK_EmployeeDesignations_Employees FOREIGN KEY(EmployeeId) REFERENCES dbo.Employees(Id) ON DELETE NO ACTION;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_EmployeeDesignations_Designations') ALTER TABLE dbo.EmployeeDesignations ADD CONSTRAINT FK_EmployeeDesignations_Designations FOREIGN KEY(DesignationId) REFERENCES dbo.Designations(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_UserRoles_AppUsers') ALTER TABLE dbo.UserRoles ADD CONSTRAINT FK_UserRoles_AppUsers FOREIGN KEY(UserId) REFERENCES dbo.AppUsers(Id) ON DELETE NO ACTION;
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_UserRoles_Roles') ALTER TABLE dbo.UserRoles ADD CONSTRAINT FK_UserRoles_Roles FOREIGN KEY(RoleId) REFERENCES dbo.Roles(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_LeaveRequests_Employees') ALTER TABLE dbo.LeaveRequests ADD CONSTRAINT FK_LeaveRequests_Employees FOREIGN KEY(EmployeeId) REFERENCES dbo.Employees(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_LeaveRequests_Teams') ALTER TABLE dbo.LeaveRequests ADD CONSTRAINT FK_LeaveRequests_Teams FOREIGN KEY(TeamId) REFERENCES dbo.Teams(Id);
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name=N'FK_LeaveRequests_ApprovedBy') ALTER TABLE dbo.LeaveRequests ADD CONSTRAINT FK_LeaveRequests_ApprovedBy FOREIGN KEY(ApprovedBy) REFERENCES dbo.Employees(Id);
GO

/* MASTER DATA */

/* Roles - intentionally only Admin, HR and Employee */
IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name=N'Admin')
    INSERT dbo.Roles(Name,Description)
    VALUES(N'Admin',N'System administrator');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name=N'HR')
    INSERT dbo.Roles(Name,Description)
    VALUES(N'HR',N'Human Resources');

IF NOT EXISTS (SELECT 1 FROM dbo.Roles WHERE Name=N'Employee')
    INSERT dbo.Roles(Name,Description)
    VALUES(N'Employee',N'Employee');
GO

/* Departments */
IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'IT')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'IT',N'Information Technology Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'HR')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'HR',N'Human Resources Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'Finance')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'Finance',N'Finance and Accounts Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'Sales')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'Sales',N'Sales and Business Development Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'Marketing')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'Marketing',N'Marketing and Brand Management Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'Customer Support')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'Customer Support',N'Customer Support and Service Department');

IF NOT EXISTS (SELECT 1 FROM dbo.Departments WHERE Name=N'Admin')
    INSERT dbo.Departments(Name,Description)
    VALUES(N'Admin',N'Admin Department');
GO

/* Teams - using the names requested by the user */
IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Backend' AND d.Name=N'IT')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Backend',Id,1 FROM dbo.Departments WHERE Name=N'IT';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Frontend' AND d.Name=N'IT')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Frontend',Id,1 FROM dbo.Departments WHERE Name=N'IT';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'QA' AND d.Name=N'IT')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'QA',Id,1 FROM dbo.Departments WHERE Name=N'IT';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Recruitment' AND d.Name=N'HR')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Recruitment',Id,1 FROM dbo.Departments WHERE Name=N'HR';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Payroll' AND d.Name=N'HR')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Payroll',Id,1 FROM dbo.Departments WHERE Name=N'HR';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Accounts' AND d.Name=N'Finance')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Accounts',Id,1 FROM dbo.Departments WHERE Name=N'Finance';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Business Development' AND d.Name=N'Sales')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Business Development',Id,1 FROM dbo.Departments WHERE Name=N'Sales';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Social Media Marketing' AND d.Name=N'Marketing')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Social Media Marketing',Id,1 FROM dbo.Departments WHERE Name=N'Marketing';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Content Marketing' AND d.Name=N'Marketing')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Content Marketing',Id,1 FROM dbo.Departments WHERE Name=N'Marketing';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Digital Marketing' AND d.Name=N'Marketing')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Digital Marketing',Id,1 FROM dbo.Departments WHERE Name=N'Marketing';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Customer Service' AND d.Name=N'Customer Support')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Customer Service',Id,1 FROM dbo.Departments WHERE Name=N'Customer Support';

IF NOT EXISTS (SELECT 1 FROM dbo.Teams t JOIN dbo.Departments d ON d.Id=t.DepartmentId WHERE t.Name=N'Technical Support' AND d.Name=N'Customer Support')
    INSERT dbo.Teams(Name,DepartmentId,IsActive)
    SELECT N'Technical Support',Id,1 FROM dbo.Departments WHERE Name=N'Customer Support';
GO

/* Designations - 25 values from the previous database */
IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Software Developer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Software Developer',N'Develops and maintains software applications',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Senior Software Developer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Senior Software Developer',N'Develops complex applications and provides technical guidance',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Backend Developer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Backend Developer',N'Develops and maintains server-side applications and APIs',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Frontend Developer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Frontend Developer',N'Develops and maintains user interfaces and frontend applications',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'QA Engineer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'QA Engineer',N'Tests software applications and identifies defects',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'HR Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'HR Executive',N'Handles employee and human resource activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'HR Manager')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'HR Manager',N'Manages human resource operations and employee activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Recruitment Specialist')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Recruitment Specialist',N'Handles employee recruitment and hiring activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Payroll Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Payroll Executive',N'Manages employee payroll and salary-related activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Accountant')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Accountant',N'Handles accounting and financial records',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Senior Accountant')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Senior Accountant',N'Manages accounting operations and financial reporting',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Financial Analyst')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Financial Analyst',N'Analyzes financial data and prepares financial reports',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Sales Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Sales Executive',N'Handles sales activities and customer relationships',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Senior Sales Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Senior Sales Executive',N'Manages sales activities and key customer accounts',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Business Development Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Business Development Executive',N'Identifies new business opportunities and develops client relationships',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Marketing Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Marketing Executive',N'Handles marketing campaigns and promotional activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Digital Marketing Specialist')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Digital Marketing Specialist',N'Manages digital marketing campaigns and online promotions',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Social Media Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Social Media Executive',N'Manages social media platforms and social media campaigns',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Content Strategist')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Content Strategist',N'Plans and manages marketing content strategies',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Customer Support Executive')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Customer Support Executive',N'Handles customer queries and support requests',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Technical Support Engineer')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Technical Support Engineer',N'Provides technical assistance and resolves technical issues',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Support Team Leader')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Support Team Leader',N'Leads customer support operations and manages support staff',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Team Leader')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Team Leader',N'Leads and manages a team',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Assistant Manager')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Assistant Manager',N'Supports department management and operational activities',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Department Manager')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Department Manager',N'Manages department operations and employees',1);

IF NOT EXISTS (SELECT 1 FROM dbo.Designations WHERE Name=N'Administration')
    INSERT dbo.Designations(Name,Description,IsActive)
    VALUES(N'Administration',N'Administration Designation',1);
GO


/* ========================================================================= */
/* INITIAL SEED: System Administrator Employee (TeamId = NULL)               */
/* ========================================================================= */
IF NOT EXISTS (SELECT 1 FROM dbo.AppUsers WHERE Username = N'admin')
BEGIN
    BEGIN TRANSACTION;

    BEGIN TRY
        DECLARE @AdminUserId INT;
        DECLARE @AdminRoleId INT;
        DECLARE @AdminDeptId INT;
        DECLARE @AdminDesignationId INT;
        DECLARE @AdminEmployeeId INT;

        -- 1. Insert AppUser (Password: Admin@123)
        INSERT INTO dbo.AppUsers
        (
            Username,
            Email,
            PasswordHash,
            PasswordSalt,
            IsActive
        )
        VALUES
        (
            N'admin',
            N'priyankaaparmar0707@gmail.com',
            0xA210370A6DBB957C341A1E72FDCC18DCEFED252361597057C44C50A9EC98FD872F9A6265BDA105F9228B7118448799E2B6F038993066278182FAFA4BAC81A938,
            0x0D25BE781D1EE410B7ED04F9BF896349A1CFBEB538165FE3D80C31F003332066,
            1
        );

        SET @AdminUserId = SCOPE_IDENTITY();

        -- 2. Lookup Master Data IDs
        SELECT @AdminRoleId = Id FROM dbo.Roles WHERE Name = N'Admin';
        SELECT @AdminDeptId = Id FROM dbo.Departments WHERE Name = N'Admin';
        SELECT @AdminDesignationId = Id FROM dbo.Designations WHERE Name = N'Administration';

        -- 3. Assign Admin Role in UserRoles
        IF @AdminRoleId IS NOT NULL
        BEGIN
            INSERT INTO dbo.UserRoles (UserId, RoleId)
            VALUES (@AdminUserId, @AdminRoleId);
        END;

        -- 4. Create Employee (TeamId is kept NULL)
        INSERT INTO dbo.Employees
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
            @AdminUserId,
            N'System Administrator',
            N'priyankaaparmar0707@gmail.com',
            @AdminDeptId,
            NULL,               -- Team is kept NULL
            NULL,               -- Supervisor is NULL
            SYSUTCDATETIME(),
            1
        );

        SET @AdminEmployeeId = SCOPE_IDENTITY();

        -- 5. Assign Administration Designation in EmployeeDesignations
        IF @AdminDesignationId IS NOT NULL
        BEGIN
            INSERT INTO dbo.EmployeeDesignations (EmployeeId, DesignationId)
            VALUES (@AdminEmployeeId, @AdminDesignationId);
        END;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO


/* ===== Auth.sql ===== */
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
GO

/* ===== Department.sql ===== */
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
GO

/* ===== Designation.sql ===== */
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
GO

/* ===== Employee.sql ===== */
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




CREATE OR ALTER PROCEDURE dbo.DeleteEmployee
    @Id INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AppUserId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Check whether employee exists
        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.Employees
            WHERE Id = @Id
        )
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 0 AS Result;
            RETURN;
        END;

        -- Get linked application user ID
        SELECT @AppUserId = AppUserId
        FROM dbo.Employees
        WHERE Id = @Id;

        -- Delete employee designation mappings
        DELETE FROM dbo.EmployeeDesignations
        WHERE EmployeeId = @Id;

        -- Delete employee record
        DELETE FROM dbo.Employees
        WHERE Id = @Id;

        -- Delete application user's role mappings first
        DELETE FROM dbo.UserRoles
        WHERE UserId = @AppUserId;

        -- Delete linked application user
        DELETE FROM dbo.AppUsers
        WHERE Id = @AppUserId;

        COMMIT TRANSACTION;

        SELECT 1 AS Result;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        -- Return the actual SQL error instead of hiding it
        THROW;
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
GO

/* ===== Leave.sql ===== */
CREATE OR ALTER PROCEDURE CreateLeave
    @EmployeeId INT,
    @LeaveType NVARCHAR(100),
    @Reason NVARCHAR(1000),
    @StartDate DATETIME2,
    @EndDate DATETIME2,
    @IsTeamLeave BIT,
    @TeamId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM Employees
        WHERE Id = @EmployeeId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF @IsTeamLeave = 1 AND @TeamId IS NULL
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    INSERT INTO LeaveRequests
    (
        EmployeeId,
        LeaveType,
        Reason,
        StartDate,
        EndDate,
        Status,
        IsTeamLeave,
        TeamId,
        CreatedAt
    )
    VALUES
    (
        @EmployeeId,
        @LeaveType,
        @Reason,
        @StartDate,
        @EndDate,
        'Pending',
        @IsTeamLeave,
        @TeamId,
        GETUTCDATE()
    );

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS LeaveId;
END;
GO





CREATE OR ALTER PROCEDURE GetMyLeaves
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        ISNULL(a.Name, '') AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    LEFT JOIN Employees a
        ON a.Id = l.ApprovedBy
    WHERE l.EmployeeId = @EmployeeId
    ORDER BY l.CreatedAt DESC;
END;
GO





CREATE OR ALTER PROCEDURE GetLeaveById
    @LeaveId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        ISNULL(a.Name, '') AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    LEFT JOIN Employees a
        ON a.Id = l.ApprovedBy
    WHERE l.Id = @LeaveId;
END;
GO




CREATE OR ALTER PROCEDURE GetAllLeaves
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        ISNULL(a.Name, '') AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    LEFT JOIN Employees a
        ON a.Id = l.ApprovedBy
    ORDER BY l.CreatedAt DESC;
END;
GO







CREATE OR ALTER PROCEDURE GetPendingLeaves
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        '' AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    WHERE l.Status = 'Pending'
    ORDER BY l.StartDate;
END;
GO







CREATE OR ALTER PROCEDURE GetTeamLeaves
    @EmployeeId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TeamId INT;

    SELECT @TeamId = TeamId
    FROM Employees
    WHERE Id = @EmployeeId;

    IF @TeamId IS NULL
    BEGIN
        RETURN;
    END;

    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        ISNULL(a.Name, '') AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    LEFT JOIN Employees a
        ON a.Id = l.ApprovedBy
    WHERE l.TeamId = @TeamId
    ORDER BY l.CreatedAt DESC;
END;
GO






CREATE OR ALTER PROCEDURE ApproveLeave
    @LeaveId INT,
    @ApprovedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests
        WHERE Id = @LeaveId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests
        WHERE Id = @LeaveId
          AND Status = 'Pending'
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM Employees
        WHERE Id = @ApprovedBy
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE LeaveRequests
    SET
        Status = 'Approved',
        ApprovedBy = @ApprovedBy,
        ApprovedDate = GETUTCDATE()
    WHERE Id = @LeaveId;

    SELECT 1 AS Result;
END;
GO






CREATE OR ALTER PROCEDURE RejectLeave
    @LeaveId INT,
    @RejectedBy INT,
    @Reason NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests
        WHERE Id = @LeaveId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests
        WHERE Id = @LeaveId
          AND Status = 'Pending'
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM Employees
        WHERE Id = @RejectedBy
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE LeaveRequests
    SET
        Status = 'Rejected',
        ApprovedBy = @RejectedBy,
        ApprovedDate = GETUTCDATE(),
        Reason = CASE
            WHEN NULLIF(LTRIM(RTRIM(@Reason)), '') IS NOT NULL
                THEN Reason + ' | HR: ' + @Reason
            ELSE Reason
        END
    WHERE Id = @LeaveId;

    SELECT 1 AS Result;
END;
GO






CREATE OR ALTER PROCEDURE GetEmployeeIdByAppUserId
    @AppUserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id AS EmployeeId
    FROM Employees
    WHERE AppUserId = @AppUserId;
END;
GO







CREATE OR ALTER PROCEDURE CancelLeave
    @LeaveId INT,
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests l
        INNER JOIN Employees e
            ON e.Id = l.EmployeeId
        WHERE l.Id = @LeaveId
          AND e.AppUserId = @UserId
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM LeaveRequests
        WHERE Id = @LeaveId
          AND Status = 'Pending'
    )
    BEGIN
        SELECT 0 AS Result;
        RETURN;
    END;

    UPDATE LeaveRequests
    SET Status = 'Cancelled'
    WHERE Id = @LeaveId;

    SELECT 1 AS Result;
END;
GO






CREATE OR ALTER PROCEDURE SearchLeaves
    @Page INT = 1,
    @PageSize INT = 10,
    @Search NVARCHAR(200) = NULL,
    @Status NVARCHAR(50) = NULL,
    @EmployeeId INT = NULL,
    @TeamId INT = NULL,
    @LeaveType NVARCHAR(100) = NULL,
    @FromDate DATETIME2 = NULL,
    @ToDate DATETIME2 = NULL,
    @SortBy NVARCHAR(50) = NULL,
    @SortDescending BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @Page < 1
        SET @Page = 1;

    IF @PageSize < 1
        SET @PageSize = 10;

    DECLARE @Offset INT;

    SET @Offset = (@Page - 1) * @PageSize;

    -- TOTAL RECORDS
    SELECT COUNT(*)
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    WHERE
        (
            @Search IS NULL
            OR LTRIM(RTRIM(@Search)) = ''
            OR e.Name LIKE '%' + @Search + '%'
        )
        AND
        (
            @Status IS NULL
            OR LTRIM(RTRIM(@Status)) = ''
            OR l.Status = @Status
        )
        AND
        (
            @EmployeeId IS NULL
            OR l.EmployeeId = @EmployeeId
        )
        AND
        (
            @TeamId IS NULL
            OR l.TeamId = @TeamId
        )
        AND
        (
            @LeaveType IS NULL
            OR LTRIM(RTRIM(@LeaveType)) = ''
            OR l.LeaveType = @LeaveType
        )
        AND
        (
            @FromDate IS NULL
            OR l.StartDate >= @FromDate
        )
        AND
        (
            @ToDate IS NULL
            OR l.EndDate <= @ToDate
        );

    -- LEAVE RECORDS
    SELECT
        l.Id,
        l.EmployeeId,
        e.Name AS EmployeeName,
        l.LeaveType,
        l.Reason,
        l.StartDate,
        l.EndDate,
        l.Status,
        l.IsTeamLeave,
        l.TeamId,
        ISNULL(t.Name, '') AS TeamName,
        l.ApprovedBy,
        ISNULL(a.Name, '') AS ApprovedByName,
        l.ApprovedDate,
        l.CreatedAt
    FROM LeaveRequests l
    INNER JOIN Employees e
        ON e.Id = l.EmployeeId
    LEFT JOIN Teams t
        ON t.Id = l.TeamId
    LEFT JOIN Employees a
        ON a.Id = l.ApprovedBy
    WHERE
        (
            @Search IS NULL
            OR LTRIM(RTRIM(@Search)) = ''
            OR e.Name LIKE '%' + @Search + '%'
        )
        AND
        (
            @Status IS NULL
            OR LTRIM(RTRIM(@Status)) = ''
            OR l.Status = @Status
        )
        AND
        (
            @EmployeeId IS NULL
            OR l.EmployeeId = @EmployeeId
        )
        AND
        (
            @TeamId IS NULL
            OR l.TeamId = @TeamId
        )
        AND
        (
            @LeaveType IS NULL
            OR LTRIM(RTRIM(@LeaveType)) = ''
            OR l.LeaveType = @LeaveType
        )
        AND
        (
            @FromDate IS NULL
            OR l.StartDate >= @FromDate
        )
        AND
        (
            @ToDate IS NULL
            OR l.EndDate <= @ToDate
        )
    ORDER BY
        CASE WHEN @SortBy = 'startdate'
                  AND @SortDescending = 0
             THEN l.StartDate END ASC,

        CASE WHEN @SortBy = 'startdate'
                  AND @SortDescending = 1
             THEN l.StartDate END DESC,

        CASE WHEN @SortBy = 'enddate'
                  AND @SortDescending = 0
             THEN l.EndDate END ASC,

        CASE WHEN @SortBy = 'enddate'
                  AND @SortDescending = 1
             THEN l.EndDate END DESC,

        CASE WHEN @SortBy = 'status'
                  AND @SortDescending = 0
             THEN l.Status END ASC,

        CASE WHEN @SortBy = 'status'
                  AND @SortDescending = 1
             THEN l.Status END DESC,

        CASE WHEN @SortBy = 'leavetype'
                  AND @SortDescending = 0
             THEN l.LeaveType END ASC,

        CASE WHEN @SortBy = 'leavetype'
                  AND @SortDescending = 1
             THEN l.LeaveType END DESC,

        CASE WHEN @SortBy = 'employee'
                  AND @SortDescending = 0
             THEN e.Name END ASC,

        CASE WHEN @SortBy = 'employee'
                  AND @SortDescending = 1
             THEN e.Name END DESC,

        CASE WHEN @SortBy IS NULL
                  OR @SortBy = ''
             THEN l.CreatedAt END DESC,

        l.Id DESC

    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;
GO
GO

/* ===== Team.sql ===== */
CREATE OR ALTER PROCEDURE CreateTeam
    @Name NVARCHAR(100), @DepartmentId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET @Name = LTRIM(RTRIM(@Name));
    IF @Name=N'' OR NOT EXISTS(SELECT 1 FROM dbo.Departments WHERE Id=@DepartmentId)
    BEGIN SELECT 0 AS Result; RETURN; END;
    IF EXISTS(SELECT 1 FROM dbo.Teams WHERE Name=@Name AND DepartmentId=@DepartmentId)
    BEGIN SELECT 0 AS Result; RETURN; END;
    INSERT dbo.Teams(Name,DepartmentId,IsActive) VALUES(@Name,@DepartmentId,1);
    SELECT 1 AS Result;
END;
GO
CREATE OR ALTER PROCEDURE GetAllTeams
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Id,t.Name,COUNT(e.Id) AS EmployeeCount,ISNULL(th.Name,N'') AS TeamHead,t.IsActive
    FROM dbo.Teams t LEFT JOIN dbo.Employees e ON e.TeamId=t.Id LEFT JOIN dbo.Employees th ON th.Id=t.TeamHeadEmployeeId
    GROUP BY t.Id,t.Name,th.Name,t.IsActive ORDER BY t.Id;
END;
GO
CREATE OR ALTER PROCEDURE GetTeamById @Id INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT t.Id,t.Name,t.DepartmentId,d.Name AS Department,t.TeamHeadEmployeeId,ISNULL(th.Name,N'') AS TeamHead,COUNT(e.Id) AS EmployeeCount,t.IsActive
    FROM dbo.Teams t INNER JOIN dbo.Departments d ON d.Id=t.DepartmentId LEFT JOIN dbo.Employees th ON th.Id=t.TeamHeadEmployeeId LEFT JOIN dbo.Employees e ON e.TeamId=t.Id
    WHERE t.Id=@Id GROUP BY t.Id,t.Name,t.DepartmentId,d.Name,t.TeamHeadEmployeeId,th.Name,t.IsActive;
END;
GO
CREATE OR ALTER PROCEDURE GetEmployeesByTeam @TeamId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Id,e.Name,e.Email,ISNULL(dg.Name,N'') AS Designation,e.IsActive
    FROM dbo.Employees e LEFT JOIN dbo.EmployeeDesignations ed ON ed.EmployeeId=e.Id LEFT JOIN dbo.Designations dg ON dg.Id=ed.DesignationId
    WHERE e.TeamId=@TeamId ORDER BY e.Name;
END;
GO
CREATE OR ALTER PROCEDURE GetTeamCount
AS
BEGIN
    SET NOCOUNT ON;
    SELECT COUNT(*) FROM dbo.Teams;
END;
GO
