DECLARE @Obj_sql VARCHAR(2000) 
DECLARE @Obj_table TABLE (DBName VARCHAR(200), 
UserName VARCHAR(250), ObjectName VARCHAR(500), 
Permission VARCHAR(200))
SET @Obj_sql='select ''?'' as DBName,U.name as username, 
O.name as object,  permission_name as permission 
FROM ?.sys.database_permissions
JOIN ?.sys.sysusers U on grantee_principal_id = uid 
JOIN ?.sys.sysobjects O on major_id = id 
WHERE ''?'' IN (''master'')
ORDER BY U.name '
INSERT @Obj_table
EXEC sp_msforeachdb @command1=@Obj_sql
SELECT * 
FROM @Obj_table
