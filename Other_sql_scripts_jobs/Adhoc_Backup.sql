USE [msdb]
GO

/****** Object:  Job [AdhocBackup]    Script Date: 7/29/2024 11:47:56 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:47:56 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'AdhocBackup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup sit14_ab]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup sit14_ab', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_ab] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_ab_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_ab-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup sit14_bc]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup sit14_bc', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_bc] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_bc_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_bc-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup sit14_cc]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup sit14_cc', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_cc] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_cc_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_cc-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup sit14_pc]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup sit14_pc', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_pc] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_pc_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_pc-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SIT14_bcpc_sap_db]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SIT14_bcpc_sap_db', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_bcpc_sap_db] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_bcpc_sap_db_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_bcpc_sap_db-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO



', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SIT14_cc_proc]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SIT14_cc_proc', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_cc_proc] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_cc_proc_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_cc_proc-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SIT14_pcbc_proc]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SIT14_pcbc_proc', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14_pcbc_proc] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14_pcbc_proc_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14_pcbc_proc-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup SIT14authdb]    Script Date: 7/29/2024 11:47:56 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup SIT14authdb', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [SIT14authdb] TO  DISK = N''\\10.150.0.101\h$\DONOTDELETE\SIT14authdb_dress_rehearsal.bak'' WITH NOFORMAT,COMPRESSION ,INIT,  NAME = N''SIT14authdb-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Mail]    Script Date: 7/29/2024 11:47:57 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Mail', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec msdb.dbo.sp_send_dbmail    
@profile_name = ''Amazon SES SMTP'',      
@Recipients = ''marcelo.gabrielliarthur@icare.nsw.gov.au;vignesh.vyas@icare.nsw.gov.au;gerard.thackray@icare.nsw.gov.au;anilreddy.koppara@icare.nsw.gov.au'',    
--@copy_recipients = ''idas@guidewire.com'',    
@Body = ''DB Backup of x centers completed in I13'',    
@Subject = ''DB Backup of x centers completed in I13'',    
@Body_format = ''HTML''', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [GWRE_IT bkp]    Script Date: 7/29/2024 11:47:57 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'GWRE_IT bkp', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--BACKUP DATABASE [gwre_it] TO  DISK = N''F:\MSSQL\Backup\gwre_it.bak'' WITH NOFORMAT, INIT,  NAME = N''gwre_it-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
--GO




use msdb
go

EXEC  msdb.dbo.sysmail_start_sp;', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'AdhocBackup', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230928, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959, 
		@schedule_uid=N'20373b19-1cca-4284-bfe3-148c802a137d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'sit14backups', 
		@enabled=0, 
		@freq_type=1, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20240328, 
		@active_end_date=99991231, 
		@active_start_time=170200, 
		@active_end_time=235959, 
		@schedule_uid=N'818863cf-09e1-4714-a6e8-686a6ed609c0'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


