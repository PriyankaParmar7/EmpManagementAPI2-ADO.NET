


EXEC CreateTeam
    @Name = 'Backend',
    @DepartmentId = 1;

EXEC GetAllTeams;

EXEC GetTeamById
    @Id = 1;

EXEC GetEmployeesByTeam
    @TeamId = 1;

EXEC GetTeamCount;