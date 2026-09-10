USE EmpManagement2DB;
GO

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