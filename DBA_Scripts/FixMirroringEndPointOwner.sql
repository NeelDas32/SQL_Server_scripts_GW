-- pause mirroring

-- login as the user that owns the endpoint

revoke connect on endpoint::Mirroring from [iscsus\sqlserver]

-- login as ISCSUS\sqladmin

DROP ENDPOINT Mirroring
  
CREATE ENDPOINT Mirroring
    STATE = STARTED
    AS TCP ( LISTENER_PORT = 5022)
    FOR DATABASE_MIRRORING (ROLE=PARTNER, AUTHENTICATION = WINDOWS NEGOTIATE, ENCRYPTION = SUPPORTED);
GO

grant connect on endpoint::Mirroring to [iscsus\sqlserver]

-- resume mirroring

