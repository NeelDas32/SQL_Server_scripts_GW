USE [msdb]
GO

/****** Object:  Job [DBCC CHECKDB - All Databases]    Script Date: 7/29/2024 11:51:45 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/29/2024 11:51:45 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBCC CHECKDB - All Databases', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will run a DBCC CHECKDB on all the databases on this instance every Sunday.  The output will can be found in the following  location: F:\SQLJobLogs\DBCC_CheckDB.log', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run DBCC CheckDB]    Script Date: 7/29/2024 11:51:45 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run DBCC CheckDB', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @Database VARCHAR(255)
DECLARE @cmd varchar(1000)


DECLARE DatabaseCursor CURSOR FOR 
SELECT name FROM master.sys.databases  
WHERE state_desc=''ONLINE'' 
and name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'') 
and name NOT IN (''preprod_bc_20201017'', ''preprod_bc_oct11'') 
and name NOT LIKE ''%_temp''
and name NOT LIKE ''%_test''
and (name like ''preprod%'' or name like ''i%'' or name like ''sit%'') -- only xCenter databases
or name in (''DH_PREPROD'',''IC_PREPROD'')
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	 SET @cmd =''DBCC CHECKDB (''+@Database+'') WITH PHYSICAL_ONLY''
-- PRINT @cmd
	 EXEC (@cmd)
FETCH NEXT FROM DatabaseCursor INTO @Database 
END 
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\DBCC_CheckDB.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Sunday CheckDB', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20120531, 
		@active_end_date=99991231, 
		@active_start_time=20000, 
		@active_end_time=235959, 
		@schedule_uid=N'06a008d1-0fbe-4906-9384-05dead9d7183'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


