USE [msdb]
GO

/****** Object:  Job [Backup All Databases_GWpreprod Environments]    Script Date: 7/29/2024 12:05:10 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 12:05:10 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup All Databases_GWpreprod Environments', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'This job will create a database backup for gwpreprod databases the online, non-snapshot databases on the server except tempdb.  The job requires the stored procedure gwre_BackupDB to exist in the GWRE_IT database.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', 
		@notify_page_operator_name=N'Alert-DBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete System DB Backup Files]    Script Date: 7/29/2024 12:05:10 PM ******/
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
		@command=N'/* Delete the backup files more than 7 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-7

EXECUTE master.dbo.xp_delete_file 0,N''F:\MSSQL\Backup\'',N''bkp'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete User DB Backup files]    Script Date: 7/29/2024 12:05:10 PM ******/
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
		@command=N'/* Delete the backup files more than 3 days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-1

EXECUTE master.dbo.xp_delete_file 0,N''\\10.150.0.101\h$\NonProdDbBackups\PreProd_gwpreprod\'',N''bkp'',@usedate,1
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Delete System Log Backup Files]    Script Date: 7/29/2024 12:05:10 PM ******/
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
/****** Object:  Step [Delete User DB Log Backup files]    Script Date: 7/29/2024 12:05:10 PM ******/
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
		@command=N'/* Delete the backup files more than 3  days old */

declare @usedate varchar (32)

set @usedate = GETDATE()-2

EXECUTE master.dbo.xp_delete_file 0,N''\\10.150.0.101\h$\NonProdLogBackups\PreProd_gwpreprod\'',N''trn'',@usedate,1


', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup System Databases]    Script Date: 7/29/2024 12:05:10 PM ******/
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
and name in (''master'',''model'',''msdb'') -- only system databases
and name not like ''GWRE_IT%''

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
/****** Object:  Step [Backup Databases]    Script Date: 7/29/2024 12:05:10 PM ******/
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
and name not like ''%_bak'' -- no temporary databases 
and name not like ''GWRE_IT%''
and name not like ''%_mask'' -- no temporary databases 
and name not like ''%_masked'' -- no temporary databases 
and name not like ''uat%'' -- no databases restored for scrubbing
and name not like ''sit13%'' -- no databases restored for scrubbing
and name not like ''%itrn%''  -- temporary database 
and name not like ''prod_unmasked_%'' -- temporary database
and name not like ''%temp%''  -- temporary database 
and name not like ''%preprod_bc_temp%''  -- temporary database 
and name not like ''%preprod_cc_temp%''  -- temporary database 
and name not like ''%preprod_pc_temp%''  -- temporary database 
and name not like ''%perf%''
and name not like ''%prod_masked%''
and name not like ''%_10145''  -- temporary database 
and name not like ''%2020%''
and name not like ''%2022%''
and name not like ''%oct11''
and name not like ''%i11%''
and name not like ''%Manual''
and name not like ''%pentest%''
and name not like ''%prod_pcbc_proc_mar312023%''
and name  like ''%gwpreprod%''			
-- https://guidewirejira.atlassian.net/browse/CLOUD-115280
order by name
OPEN cur_loop

FETCH NEXT FROM cur_loop
INTO @DBName
WHILE (@@FETCH_STATUS<>-1)
BEGIN

IF (@@FETCH_STATUS<>-2)
-- PRINT ''Backing Up '' + @DBName
exec [GWRE_IT].[dbo].[gwre_BackupDB] @DBName, 0, ''\\10.150.0.101\h$\NonProdDbBackups\PreProd_gwpreprod\'', 0

FETCH NEXT FROM cur_loop
INTO @DBName

END

CLOSE cur_loop

DEALLOCATE cur_loop

', 
		@database_name=N'master', 
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
		@active_start_date=20210522, 
		@active_end_date=99991231, 
		@active_start_time=100, 
		@active_end_time=235959, 
		@schedule_uid=N'66316432-7e16-4c79-b1bc-395ca1471010'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


