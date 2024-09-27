USE [msdb]
GO

/****** Object:  Job [Backup Transaction Logs]    Script Date: 7/29/2024 12:05:29 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 7/29/2024 12:05:29 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Backup Transaction Logs', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup model Logs]    Script Date: 7/29/2024 12:05:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup model Logs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec [GWRE_IT].[dbo].[gwre_BackupDBLogs] model,''F:\LogBackups\'',''trn'',1,''cloudopsdba@guidewire.com'',0
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup ICARE database logs except system databases & GWpreprod]    Script Date: 7/29/2024 12:05:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup ICARE database logs except system databases & GWpreprod', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=3, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @name VARCHAR(50) -- database name   
DECLARE @path VARCHAR(256) -- path for backup files   
DECLARE @fileName VARCHAR(256) -- filename for backup   
DECLARE @fileDate VARCHAR(20) -- used for file name  

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)  
   + ''_''  
   + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),'':'','''') 

DECLARE db_cursor CURSOR FOR   
SELECT  name  
FROM sys.databases  
WHERE name NOT IN (''master'',''model'',''msdb'',''tempdb'',''GWRE_IT'')
and name not like ''sit13%''
and name not like ''GWRE_IT%''
and name not like ''prod_unmasked%''
and name not like ''PC_i4%''
and name not like ''%mask%''
and name not like ''_%_temp''
and name not like ''_%_10145''
and name not like ''%Splicing%''
and name not like ''%dev2%''
and name not like ''%perf%''
and name not like ''%perf2%''
and name not like ''%masked%''
and name not like ''%2020%''
and name not like ''%2022%''
and name not like ''%oct11''
and name not like ''%prod_%''
and name not like ''%Manual''
and name not like ''%gwpreprod%''						-- https://guidewirejira.atlassian.net/browse/CLOUD-115280
and DATABASEPROPERTYEX(name, ''Recovery'') IN (''FULL'',''BULK_LOGGED'') 
and state_desc=''ONLINE''

OPEN db_cursor    
FETCH NEXT FROM db_cursor INTO @name    

WHILE @@FETCH_STATUS = 0    
BEGIN
       SET @path = ''\\10.150.0.101\h$\NonProdLogBackups\PreProd\'' 
       SET @path = @path + @name + ''\''       
       EXEC xp_create_subdir @path 
       SET @fileName = @path + @name + ''_'' + @fileDate + ''.trn''   
       BACKUP LOG @name TO DISK = @fileName  WITH  RETAINDAYS = 7 
       FETCH NEXT FROM db_cursor INTO @name    
END    

CLOSE db_cursor', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\UserDBLogBackups.log', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup GWpreprod database logs except system databases]    Script Date: 7/29/2024 12:05:30 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup GWpreprod database logs except system databases', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=1, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @name VARCHAR(50) -- database name   
DECLARE @path VARCHAR(256) -- path for backup files   
DECLARE @fileName VARCHAR(256) -- filename for backup   
DECLARE @fileDate VARCHAR(20) -- used for file name  

SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112)  
   + ''_''  
   + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),'':'','''') 

DECLARE db_cursor CURSOR FOR   
SELECT  name  
FROM sys.databases  
WHERE name NOT IN (''master'',''model'',''msdb'',''tempdb'')
and name not like ''sit13%''
and name not like ''GWRE_IT%''
and name not like ''prod_unmasked%''
and name not like ''PC_i4%''
and name not like ''%mask%''
and name not like ''_%_temp''
and name not like ''_%_10145''
and name not like ''%Splicing%''
and name not like ''%dev2%''
and name not like ''%perf%''
and name not like ''%perf2%''
and name not like ''%masked%''
and name not like ''%2020%''
and name not like ''%2022%''
and name not like ''%oct11''
and name not like ''%Manual''
and name  like ''%gwpreprod%''							-- https://guidewirejira.atlassian.net/browse/CLOUD-115280
and DATABASEPROPERTYEX(name, ''Recovery'') IN (''FULL'',''BULK_LOGGED'') 
and state_desc=''ONLINE''

OPEN db_cursor    
FETCH NEXT FROM db_cursor INTO @name    

WHILE @@FETCH_STATUS = 0    
BEGIN
       SET @path = ''\\10.150.0.101\h$\NonProdLogBackups\PreProd_gwpreprod\'' 
       SET @path = @path + @name + ''\''       
       EXEC xp_create_subdir @path 
       SET @fileName = @path + @name + ''_'' + @fileDate + ''.trn''   
       BACKUP LOG @name TO DISK = @fileName  WITH  RETAINDAYS = 7 
       FETCH NEXT FROM db_cursor INTO @name    
END    

CLOSE db_cursor', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Logbackups', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200329, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'b72620f9-5770-44cf-b371-8caebe5d2a5d'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


