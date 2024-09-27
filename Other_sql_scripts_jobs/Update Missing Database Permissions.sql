USE [msdb]
GO

/****** Object:  Job [Update Missing Database Permissions]    Script Date: 7/29/2024 12:04:13 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 12:04:13 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Update Missing Database Permissions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will run scripts to uodate any missing database permissions that occur due to the refreshing of the databases adn the logins not done properly in the jobs.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ICAREPREPROD\sqlsa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update the Read-Only group access to All databases]    Script Date: 7/29/2024 12:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update the Read-Only group access to All databases', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Update GWRE-CLOUD\ICARE-PreprodDb-RO
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases 
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''GWRE-CLOUD\ICARE-PreprodDb-RO'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[GWRE-CLOUD\ICARE-PreprodDb-RO]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-PreprodDb-RO]''''); 
		ALTER USER [GWRE-CLOUD\ICARE-PreprodDb-RO] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-PreprodDb-RO];
	END''

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update ICARE-SUPPORT-RO-PROD group access to all databases]    Script Date: 7/29/2024 12:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update ICARE-SUPPORT-RO-PROD group access to all databases', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Update GWRE-CLOUD\ICARE-SUPPORT-RO-PROD 
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases 
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]''''); 
		ALTER USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD];
	END''

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update ICARE-PreprodDB-RO-DM-Vendors group access to all databases]    Script Date: 7/29/2024 12:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update ICARE-PreprodDB-RO-DM-Vendors group access to all databases', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Update GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
and name not like ''pentest%''
and name not like ''preprod%''
and name not like ''%unmasked%''
and name not like ''%mask%''
and name not like ''%mask%''
and name <> ''CC_USER_ACCESS_1862''
and name <> ''Testdb_Manual''
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors]''''); 
		ALTER USER [GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-PreprodDB-RO-DM-Vendors];
	END''

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update the Read-Write group read access to xCenter databases]    Script Date: 7/29/2024 12:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update the Read-Write group read access to xCenter databases', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Run in each ICARE Preprod XCenter databases
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
and name not like ''ETL%''
and (name like ''%_ab''
or name like ''%_bc''
or name like ''%_cc''
or name like ''%_pc''
or name like ''%_uaa'')
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		ALTER USER [GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW];
	END''

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update the Read-Write group read-write access to DHIC and ETL databases]    Script Date: 7/29/2024 12:04:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update the Read-Write group read-write access to DHIC and ETL databases', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Run in each ICARE DHIC and ETL databases
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
and (name like ''GXR%'' 
or name like ''cognos%''
or name like ''ETL%'' 
or name like ''%ETL%'' 
or name like ''%DH%'' 
or name like ''%IC%'' )
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datawriter '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_ddladmin '''' +'''','''' + ''''[GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW]''''); 
		ALTER USER [GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [GWRE-CLOUD\ICARE-DHIC-PreprodDb-RW];
	END''

     -- PRINT (@cmd)
     EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update the ds_jobserver login read-only access to xCenter Databases]    Script Date: 7/29/2024 12:04:14 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update the ds_jobserver login read-only access to xCenter Databases', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Run in each ICARE Preprod XCenter databases
declare @DBName varchar(32)
-- declare @DomainLogin varchar(32)
DECLARE @cmd varchar(1000);

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'',''SSISDB'') -- not system databases 
and name not in (''DH_PROD_beforedeployment_with_diff_2'',''IC_PROD_beforedeployment_with_diff_2'',''prod_ab_beforedeployment_with_diff_2'',''prod_bc_beforedeployment_with_diff_2'',''prod_cc_beforedeployment_with_diff_2'',''prod_pc_beforedeployment_with_diff_2'')
and name not like ''ETL%''
and (name like ''%_ab''
or name like ''%_bc''
or name like ''%_cc''
or name like ''%_pc''
or name like ''%_uaa'')
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

-- set @DomainLogin = ''''''''+@DBName+''''''''

IF (@@FETCH_STATUS<>-2)

SET @cmd = ''USE ''+''[''+@DBName+''];'' + ''IF NOT EXISTS (SELECT ''''X''''
            FROM ''+''[''+@DBName+'']''+''.dbo.sysusers
                WHERE name = ''''ICAREPREPROD\ds_jobserver'''')''+''
    BEGIN 
		EXEC (''''sp_grantdbaccess'''' + ''''[ICAREPREPROD\ds_jobserver]''''); 
		EXEC (''''sp_addrolemember '''' + ''''db_datareader '''' +'''','''' + ''''[ICAREPREPROD\ds_jobserver]''''); 
		ALTER USER [ICAREPREPROD\ds_jobserver] WITH DEFAULT_SCHEMA = [dbo];
		DROP SCHEMA [ICAREPREPROD\ds_jobserver];
	END''

--  PRINT (@cmd)
    EXEC (@cmd)

FETCH NEXT FROM cur_loop
INTO @DBName

END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Update Missing Database Permissions', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=8, 
		@freq_subday_interval=12, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20201020, 
		@active_end_date=99991231, 
		@active_start_time=50000, 
		@active_end_time=45959, 
		@schedule_uid=N'de641a84-fe89-4105-adf4-f1a42c62835f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


