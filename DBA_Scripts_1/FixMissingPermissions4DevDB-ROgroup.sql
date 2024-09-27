-- Update GWRE-CLOUD\ICARE-DevDb-RO
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> 'tempdb' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in ('master','model','msdb','GWRE_IT','SSISDB') -- not system databases 
and name not in ('preprod_ab_02252022','preprod_bc_20201017','preprod_bc_oct11','CC_USER_ACCESS_1862') -- not system databases 
and name not like '%preprod%'
and name not like '%pentest%'
and name not like '%prod_masked%'
and name not like '%unmasked%'
and name not like '%_temp%'
and name not like '%_test'
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''+@DBName+''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = 'USE '+'['+@DBName+'];' + 'IF NOT EXISTS (SELECT ''X''
            FROM '+'['+@DBName+']'+'.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\ICARE-DevDb-RO'')'+'
    BEGIN 
		EXEC (''sp_grantdbaccess'' + ''[GWRE-CLOUD\ICARE-DevDb-RO]''); 
		EXEC (''sp_addrolemember '' + ''db_datareader '' +'','' + ''[GWRE-CLOUD\ICARE-DevDb-RO]''); 
		ALTER USER [GWRE-CLOUD\ICARE-DevDb-RO] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-DevDb-RO];
	END'

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END

