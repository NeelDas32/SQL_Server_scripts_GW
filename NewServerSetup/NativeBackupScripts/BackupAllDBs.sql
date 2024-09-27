USE [msdb]
GO

/****** Object:  Job [Backup All Databases]    Script Date: 9/17/2018 10:27:33 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 9/17/2018 10:27:33 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup All Databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will create a database backup for all the online, non-snapshot databases on the server except tempdb.  The job requires the stored procedure gwre_BackupDB to exist in the GWRE_IT database.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete System DB Backup Files]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete System DB Backup Files', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 14 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-13

EXECUTE master.dbo.xp_delete_file 0,N''F:\MSSQL\Backup\'',N''bkp'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete User DB Backup files]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete User DB Backup files', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 14 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-13

EXECUTE master.dbo.xp_delete_file 0,N''\\WSFCNODE2\F$\MSSQL\Backup\'',N''bkp'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete System Log Backup Files]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete System Log Backup Files', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 7 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-6

EXECUTE master.dbo.xp_delete_file 0,N''F:\LogBackups\'',N''trn'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete User DB Log Backup files]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete User DB Log Backup files', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 14 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-13

EXECUTE master.dbo.xp_delete_file 0,N''\\WSFCNODE2\F$\LogBackups\'',N''trn'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup System Databases]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup System Databases', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @DBName varchar(32)

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name in (''master'',''model'',''msdb'',''GWRE_IT'') -- only system databases 
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

IF (@@FETCH_STATUS<>-2)
-- PRINT ''Backing Up '' + @DBName
exec [GWRE_IT].[dbo].[gwre_BackupDB] @DBName, 0, ''F:\MSSQL\Backup\'', 0

FETCH NEXT FROM cur_loop
INTO @DBName

END

CLOSE cur_loop

DEALLOCATE cur_loop

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Databases]    Script Date: 9/17/2018 10:27:33 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Databases', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @DBName varchar(32)

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
and name not in (''master'',''model'',''msdb'',''GWRE_IT'') -- no system databases 
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

IF (@@FETCH_STATUS<>-2)
-- PRINT ''Backing Up '' + @DBName
exec [GWRE_IT].[dbo].[gwre_BackupDB] @DBName, 0, ''\\WSFCNODE2\F$\MSSQL\Backup\'', 0

FETCH NEXT FROM cur_loop
INTO @DBName

END

CLOSE cur_loop

DEALLOCATE cur_loop

', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\DatabaseBackupJob.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup Databases', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170626, 
		@active_end_date=99991231, 
		@active_start_time=53000, 
		@active_end_time=235959, 
		@schedule_uid=N'71f1ff60-925a-45ba-8110-daeed8923c37'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


USE [msdb]
GO

/****** Object:  Job [Backup All Databases]    Script Date: 04/05/2018 20:52:26 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]]    Script Date: 04/05/2018 20:52:26 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup All Databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will create a database backup for all the online, non-snapshot databases on the server except tempdb.  The job requires the stored procedure gwre_BackupDB to exist in the GWRE_IT database.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete DB Backup Files]    Script Date: 07/22/2017 20:52:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete DB Backup Files', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 7 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-6

EXECUTE master.dbo.xp_delete_file 0,N''F:\MSSQL\Backup\'',N''bkp'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete Log Backup Files]    Script Date: 07/22/2017 20:52:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Delete Log Backup Files', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/* Delete the backup files more than 7 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-6

EXECUTE master.dbo.xp_delete_file 0,N''F:\LogBackups\'',N''trn'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup Databases]    Script Date: 07/22/2017 20:52:26 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup Databases', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @DBName varchar(32)

DECLARE cur_loop CURSOR 
FOR
select name from sys.databases
where name <> ''tempdb'' -- cannot backup tempdb
and state = 0 -- online databases only
and source_database_id IS NULL -- no snapshot databases
order by name

OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

IF (@@FETCH_STATUS<>-2)
-- PRINT ''Backing Up '' + @DBName
exec [GWRE_IT].[dbo].[gwre_BackupDB] @DBName, 0, ''F:\MSSQL\Backup\'', 0

FETCH NEXT FROM cur_loop
INTO @DBName

END

CLOSE cur_loop

DEALLOCATE cur_loop

', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\DatabaseBackupJob.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Backup Databases', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170626, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'71f1ff60-925a-45ba-8110-daeed8923c37'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


