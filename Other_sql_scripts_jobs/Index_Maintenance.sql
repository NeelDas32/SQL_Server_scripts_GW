USE [msdb]
GO

/****** Object:  Job [IndexMaintenance]    Script Date: 7/29/2024 11:58:55 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/29/2024 11:58:55 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'IndexMaintenance', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will rebuild indexes for all databases based on their fragmentation. When fragmented more than 30% the indexes will be rebuilt.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Rebuild Indexes]    Script Date: 7/29/2024 11:58:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Rebuild Indexes', 
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
name NOT IN (''master'', ''model'', ''msdb'', ''tempdb'',''cognos'') 
and name not like  (''%mask%'')
and name not like (''%ETL%'')
and name not like (''%GW%'')
and name not like (''%pen%'')
and name not like (''%temp%'')
and name not like (''%ssisdb%'')
and name not like (''%test%'')
and name not like (''%oct11'')
and name not like (''%user%'')
and name not like (''%02252022'')
and name not like(''%GWRE_IT%'')
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	 SET @cmd =''EXECUTE [GWRE_IT_NEW].[dbo].[gwre_RebuildIndexes] ''+@Database
	 EXEC (@cmd)
FETCH NEXT FROM DatabaseCursor INTO @Database 
END 
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor', 
		@database_name=N'master', 
		@flags=8
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect Fragementation]    Script Date: 7/29/2024 11:58:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect Fragementation', 
		@step_id=2, 
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
name IN (''prod_unmasked_ab'',''prod_unmasked_cc'', ''prod_unmasked_bc'', ''prod_unmasked_pc'',''i14_ab'',''i14_bc'',''i14_cc'',''i14_pc'',''i11_ab'',''i11_cc'',''i11_bc'',''i11_pc''
,''i17_ab'',''i17_bc'',''i17_cc'',''i17_pc'',''sit14_ab'',''sit14_bc'',''sit14_cc'',''sit14_pc'',''preprod_ab'',''preprod_bc'',''preprod_cc'',''preprod_pc'')
ORDER BY 1  

OPEN DatabaseCursor  

FETCH NEXT FROM DatabaseCursor INTO @Database 

WHILE @@FETCH_STATUS = 0 
BEGIN 
	 SET @cmd =''EXECUTE [GWRE_IT_NEW].[dbo].[gwre_IndexfragmentationReport]''+@Database
	 EXEC (@cmd)
FETCH NEXT FROM DatabaseCursor INTO @Database 
END 
CLOSE DatabaseCursor  
DEALLOCATE DatabaseCursor', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [FragmentationreportinMail]    Script Date: 7/29/2024 11:58:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'FragmentationreportinMail', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec  IndexFragmentationinMail', 
		@database_name=N'GWRE_IT_NEW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20210325, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'434d8b81-f741-4ba2-8ff7-d8f2e0d0648d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


