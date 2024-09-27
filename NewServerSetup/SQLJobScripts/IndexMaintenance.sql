USE [msdb]
GO

/****** Object:  Job [IndexMaintenance]    Script Date: 06/14/2014 04:16:20 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 06/14/2014 04:16:20 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexMaintenance', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will rebuild or reorganize indexes for all databases based on their fragmentation.  When fragmented between 10 and 30 percent the indexes will be reorganized.  When fragmented more than 30% the indexes will be rebuilt.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [IndexReorgRebuild]    Script Date: 06/14/2014 04:16:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'IndexReorgRebuild', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
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
WHERE state_desc=''ONLINE'' and 
name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'')
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	 SET @cmd =''EXECUTE [ISCS_IT].[dbo].[iscs_IndexMaintenance] ''+@Database
	 EXEC (@cmd)
FETCH NEXT FROM DatabaseCursor INTO @Database 
END 
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor', 
		@database_name=N'master', 
		@output_file_name=N'U:\SQLJobLogs\IndexMaintenance.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Statistics]    Script Date: 06/14/2014 04:16:20 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics', 
		@step_id=2, 
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
and name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'', ''distribution'')
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	 SET @cmd =''EXECUTE [ISCS_IT].[dbo].[iscs_UpdateStatistics] ''+@Database
	 EXEC (@cmd)
FETCH NEXT FROM DatabaseCursor INTO @Database 
END 
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor', 
		@database_name=N'master', 
		@output_file_name=N'U:\SQLJobLogs\UpdateStatistics_Sat.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'IndexMaintenance', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20110610, 
		@active_end_date=99991231, 
		@active_start_time=220100, 
		@active_end_time=235959, 
		@schedule_uid=N'20572ff3-e427-4e73-8e57-5c3e6882ac64'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO

