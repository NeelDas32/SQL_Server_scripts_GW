USE [msdb]
GO

/****** Object:  Job [View_Preprod_server_Files]    Script Date: 7/29/2024 12:04:42 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 12:04:42 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'View_Preprod_server_Files', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job is created for icare-DBA to view the files & folder into the new backup server.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [View_Bkp_server_Files]    Script Date: 7/29/2024 12:04:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'View_Bkp_server_Files', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Use GWRE_IT_NEW
GO
--CREATE TABLE Dir_files
--(
--   COL1 varchar(max)
--)
Truncate Table GWRE_IT_NEW..Dir_files

INSERT INTO GWRE_IT_NEW..Dir_files
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir Y:\MSSQL\DATA\''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.101\h$\NonProdDbBackups\PreProd''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.101\h$\NonProdDbBackups\PreProd\i17_ab''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.101\h$\preprod_maskedbackups''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\DbBackups\WSFCNODE1\prod_ab''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\DbBackups\WSFCNODE1\prod_bc''
EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\DbBackups\WSFCNODE1\prod_cc''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\DbBackups\WSFCNODE1\prod_pc''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\RestoreDB\prod_ab''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\RestoreDB\prod_bc''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\RestoreDB\prod_cc''
--EXECUTE [master].[dbo].[xp_cmdshell] ''dir \\10.150.0.28\i$\RestoreDB\prod_pc''

--select * from GWRE_IT..Dir_files
------------', 
		@database_name=N'master', 
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


