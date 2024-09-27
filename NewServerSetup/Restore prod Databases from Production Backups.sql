--Replace ENTER_DB_NAME with an actual db name only main db needed  as prodCUST - 38 occurancies
--Replace ENTER_SERVER_NAME with an actual server name  - 3 occurancies

USE [msdb]
GO

/****** Object:  Job [Restore ENTER_DB_NAME Databases from Production Backups]    Script Date: 7/11/2014 5:03:18 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/11/2014 5:03:18 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Restore ENTER_DB_NAME Databases from Production Backups', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job restores the production database backups.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill ENTER_DB_NAME Connections]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill ENTER_DB_NAME Connections', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @dbname sysname
 
SET @dbname = ''ENTER_DB_NAME''--- Please enter the DB Name here
 
DECLARE @spid int
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname)

WHILE @spid IS NOT NULL
BEGIN
EXECUTE (''KILL '' + @spid)
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname) AND spid > @spid
END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore ENTER_DB_NAME Database]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore ENTER_DB_NAME Database', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ResultCode	INT

EXEC @ResultCode = [master].[dbo].[xp_ss_instantrestore] 
	@database = N''ENTER_DB_NAME'', 
	@filename = N''U:\DbBackup\ENTER_DB_NAME_full.safe'', 
	@disconnectusers = N''1'', 
	@replace = N''1'', 
	@server = N''ENTER_SERVER_NAME.iscsus.net'', 
	@withmove = N''"ENTER_DB_NAME" "F:\Data\ENTER_DB_NAME.mdf"'', 
	@withmove = N''"ENTER_DB_NAME_log" "L:\Logs\ENTER_DB_NAME_log.ldf"'', 
	@includelogins = N''1''
	
IF(@ResultCode != 0)
	RAISERROR(''One or more operations failed to complete.'', 16, 1);

', 
		@database_name=N'master', 
		@output_file_name=N'U:\SQLJobLogs\Refresh_DB_Logs\RefreshDatabase_ENTER_DB_NAME.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill ENTER_DB_NAME Connections]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill ENTER_DB_NAME Connections', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @dbname sysname
 
SET @dbname = ''ENTER_DB_NAME''--- Please enter the DB Name here
 
DECLARE @spid int
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname)

WHILE @spid IS NOT NULL
BEGIN
EXECUTE (''KILL '' + @spid)
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname) AND spid > @spid
END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore ENTER_DB_NAME Database]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore ENTER_DB_NAME Database', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ResultCode	INT

EXEC @ResultCode = [master].[dbo].[xp_ss_instantrestore] 
	@database = N''ENTER_DB_NAME'', 
	@filename = N''U:\DbBackup\ENTER_DB_NAME_full.safe'', 
	@disconnectusers = N''1'', 
	@replace = N''1'', 
	@server = N''ENTER_SERVER_NAME.iscsus.net'', 
	@withmove = N''"ENTER_DB_NAME" "F:\Data\ENTER_DB_NAME.mdf"'', 
	@withmove = N''"ENTER_DB_NAME_log" "L:\Logs\ENTER_DB_NAME_log.ldf"'', 
	@includelogins = N''1''
	

IF(@ResultCode != 0)
	RAISERROR(''One or more operations failed to complete.'', 16, 1);

', 
		@database_name=N'master', 
		@output_file_name=N'U:\SQLJobLogs\Refresh_SupportDB_Logs\RefreshDatabase_ENTER_DB_NAME.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill ENTER_DB_NAME Connections]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill ENTER_DB_NAME Connections', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @dbname sysname
 
SET @dbname = ''ENTER_DB_NAME''--- Please enter the DB Name here
 
DECLARE @spid int
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname)

WHILE @spid IS NOT NULL
BEGIN
EXECUTE (''KILL '' + @spid)
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname) AND spid > @spid
END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore ENTER_DB_NAME Database]    Script Date: 7/11/2014 5:03:18 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore ENTER_DB_NAME Database', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ResultCode	INT

EXEC @ResultCode = [master].[dbo].[xp_ss_instantrestore] 
	@database = N''ENTER_DB_NAME'', 
	@filename = N''U:\DbBackup\ENTER_DB_NAME_full.safe'', 
	@disconnectusers = N''1'', 
	@replace = N''1'', 
	@server = N''ENTER_SERVER_NAME.iscsus.net'', 
	@withmove = N''"ENTER_DB_NAME" "F:\Data\ENTER_DB_NAME.mdf"'', 
	@withmove = N''"ENTER_DB_NAME_log" "L:\Logs\ENTER_DB_NAME_log.ldf"'', 
	@includelogins = N''1''
	

IF(@ResultCode != 0)
	RAISERROR(''One or more operations failed to complete.'', 16, 1);', 
		@database_name=N'master', 
		@output_file_name=N'U:\SQLJobLogs\Refresh_SupportDB_Logs\RefreshDatabase_ENTER_DB_NAME.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


