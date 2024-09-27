-- Check Servername and InstanceName

SELECT SERVERPROPERTY('ServerName') as [InstanceName]
, SERVERPROPERTY('ComputerNamePhysicalNetBIOS') as[ComputerNamePhysicalNetBIOS]
, @@SERVERNAME as ServerName

/*
If they do not match, to Fix the Problem...

If the @@ServerName property is NULL, running the following will fix the issue

EXEC sp_addserver '<LocalServerName>', local;
GO

If the @@ServerName property is incorrect, run the following to correct the issue:

EXEC sp_dropserver 'old_name';
GO
EXEC sp_addserver 'new_name', 'local';
GO

Either fix requires you restart the SQL Server instance.
*/