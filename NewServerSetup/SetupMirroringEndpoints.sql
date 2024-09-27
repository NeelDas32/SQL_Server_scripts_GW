-- On the DTR server

-- USE master ;

CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (ROLE=WITNESS, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = SUPPORTED);
GO

grant connect on endpoint::Mirroring to [iscsus\sqlserver]

-- SELECT role_desc, state_desc, *  FROM sys.database_mirroring_endpoints

-- On the DB server

-- USE master ;

CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (ROLE=PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = SUPPORTED);
GO

grant connect on endpoint::Mirroring to [iscsus\sqlserver]

-- On the MIR server

-- USE master ;

CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (ROLE=PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = SUPPORTED);
GO

grant connect on endpoint::Mirroring to [iscsus\sqlserver]