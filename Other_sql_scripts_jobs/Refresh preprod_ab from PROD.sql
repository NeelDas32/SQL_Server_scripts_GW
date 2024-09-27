USE [msdb]
GO

/****** Object:  Job [preprod_ab refresh from PROD]    Script Date: 7/29/2024 12:02:35 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 12:02:35 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'preprod_ab refresh from PROD', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job refreshes the preprod_ab database from prod_ab.  It requires \\10.150.0.28\I$\RestoreDB\prod_ab_Full.safe to be availableon AU1-BKP01', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Transaction Log backup job]    Script Date: 7/29/2024 12:02:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Transaction Log backup job', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb
GO

EXEC dbo.sp_update_job
    @job_name = N''Backup Transaction Logs'',
    @enabled = 0
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections]    Script Date: 7/29/2024 12:02:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'---- Kill all current connections

DECLARE @cmdKill VARCHAR(50)

DECLARE killCursor CURSOR FOR
SELECT ''KILL '' + Convert(VARCHAR(5), p.spid)
FROM master.dbo.sysprocesses AS p
WHERE p.dbid = db_id(''preprod_ab'')

OPEN killCursor
FETCH killCursor INTO @cmdKill

WHILE 0 = @@fetch_status
BEGIN
EXECUTE (@cmdKill) 
FETCH killCursor INTO @cmdKill
END
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore preprod_ab]    Script Date: 7/29/2024 12:02:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore preprod_ab', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]

ALTER DATABASE [preprod_ab] SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

RESTORE DATABASE [preprod_ab] FROM  DISK = N''\\10.150.0.101\H$\Prod_DB_Backups\prod_ab_beforedeployment_with_diff.bak''  WITH  FILE = 1, 
 MOVE N''prod_ab'' TO N''Y:\MSSQL\DATA\preprod_ab.mdf'', 
  MOVE N''prod_ab_log'' TO N''E:\MSSQL\LOG\preprod_ab_log.ldf'',  NOUNLOAD, REPLACE, STATS = 5

GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Logical file name]    Script Date: 7/29/2024 12:02:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Logical file name', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master];
GO

ALTER DATABASE [preprod_ab] MODIFY FILE ( NAME = prod_ab, NEWNAME = preprod_ab );
GO

ALTER DATABASE [preprod_ab] MODIFY FILE ( NAME = prod_ab_log, NEWNAME = preprod_ab_log );
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adjust login and owner]    Script Date: 7/29/2024 12:02:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adjust login and owner', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- Setup DB owner

USE [preprod_ab]
GO
EXEC dbo.sp_changedbowner @loginame = N''icarepreprod\sqlsa'', @map = false
GO
--Remove prod logins

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''prod_ab'')
DROP USER [prod_ab];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'')
DROP USER [GWRE-CLOUD\GWRE-APOLLO-RO-PROD];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
DROP USER [GWRE-CLOUD\GWRE-SE-RO-PROD];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-FR-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-FR-RO-PROD-USERS];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-ProdDB-RO'')
DROP USER [GWRE-CLOUD\ICARE-ProdDB-RO];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SI-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-SI-RO-PROD-USERS];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''icare_prod_ro_user'')
DROP USER [icare_prod_ro_user];
GO

use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''gwre-cloud\icare-dhic-proddb-rw'')
DROP USER [gwre-cloud\icare-dhic-proddb-rw];
GO
use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''ICAREPROD\ds_jobserver'')
DROP USER [ICAREPROD\ds_jobserver];
GO
use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-DevDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-DevDb-RO];
GO
use [preprod_ab]
go
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''test1'')
DROP USER [test1];
GO

-- Create GWRE-CLOUD\GWRE-SE-RO-NONPROD
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-NONPROD'')
DROP USER [GWRE-CLOUD\GWRE-SE-RO-NONPROD];
GO
CREATE USER [GWRE-CLOUD\GWRE-SE-RO-NONPROD] FOR LOGIN [GWRE-CLOUD\GWRE-SE-RO-NONPROD]
GO
ALTER ROLE [db_datareader] ADD MEMBER [GWRE-CLOUD\GWRE-SE-RO-NONPROD]

-- Create GWRE-CLOUD\ICARE-PreprodDb-RO
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-PreprodDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-PreprodDb-RO];
GO
CREATE USER [GWRE-CLOUD\ICARE-PreprodDb-RO] FOR LOGIN [GWRE-CLOUD\ICARE-PreprodDb-RO]
GO
ALTER ROLE [db_datareader] ADD MEMBER [GWRE-CLOUD\ICARE-PreprodDb-RO]

-- Create GWRE-CLOUD\ICARE-PreprodDb-RO
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'')
DROP USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD];
GO
CREATE USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] FOR LOGIN [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]
GO
ALTER ROLE [db_datareader] ADD MEMBER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]


-- Create ICAREPREPROD\ds_jobserver
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''ICAREPREPROD\ds_jobserver'')
DROP USER [ICAREPREPROD\ds_jobserver];
GO
CREATE USER [ICAREPREPROD\ds_jobserver] FOR LOGIN [ICAREPREPROD\ds_jobserver]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ICAREPREPROD\ds_jobserver]

-- Create icare_preprod_ro_user
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''icare_preprod_ro_user'')
DROP USER [icare_preprod_ro_user];
GO
CREATE USER [icare_preprod_ro_user] FOR LOGIN [icare_preprod_ro_user]
GO
ALTER ROLE [db_datareader] ADD MEMBER [icare_preprod_ro_user]

-- Create GWRE-CLOUD\GWRE-SE-RO-PROD
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
DROP USER [ICAREPREPROD\ds_jobserver];
GO
CREATE USER [GWRE-CLOUD\GWRE-SE-RO-PROD] FOR LOGIN [GWRE-CLOUD\GWRE-SE-RO-PROD]
GO
ALTER ROLE [db_datareader] ADD MEMBER [GWRE-CLOUD\GWRE-SE-RO-PROD]

-- Create preprod_ab
USE [preprod_ab]
IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''preprod_ab'')
DROP USER [preprod_ab];
GO
CREATE USER [preprod_ab] FOR LOGIN [preprod_ab]
GO
ALTER ROLE [db_owner] ADD MEMBER [preprod_ab]

--Create dsjobserver

USE [preprod_ab]

IF EXISTS (SELECT name FROM preprod_ab.dbo.sysusers WHERE name = ''ICAREPREPROD\ds_jobserver'')
DROP USER [ICAREPREPROD\ds_jobserver];
GO
CREATE USER [ICAREPREPROD\ds_jobserver] FOR LOGIN [ICAREPREPROD\ds_jobserver]
GO
ALTER ROLE [db_datareader] ADD MEMBER [ICAREPREPROD\ds_jobserver]

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Shrink Log file]    Script Date: 7/29/2024 12:02:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Shrink Log file', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [preprod_ab]
DBCC SHRINKFILE (N''preprod_ab_log'',51200)
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add database to AoA]    Script Date: 7/29/2024 12:02:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add database to AoA', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="preprod_ab" -i "F:\SQLJobScripts\AddDBAoA.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Enable Transactional log backup job]    Script Date: 7/29/2024 12:02:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Enable Transactional log backup job', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb
GO

EXEC dbo.sp_update_job
    @job_name = N''Backup Transaction Logs'',
    @enabled = 1
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore database]    Script Date: 7/29/2024 12:02:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @ResultCode	INT

EXEC @ResultCode = [master].[dbo].[xp_ss_restore] 
	@database = N''preprod_ab'', 
	@filename = N''\\10.150.0.28\I$\RestoreDB\prod_ab\prod_ab_Full.safe'', 
	@disconnectusers = N''1'', 
	@replace = N''1'', 
	@server = N''wsfcnode1'', 
	@withmove = N''"prod_ab" "D:\MSSQL\DATA\preprod_ab.mdf"'', 
	@withmove = N''"prod_ab_log" "E:\MSSQL\LOG\preprod_ab_log.ldf"'', 
	@includelogins = N''1'', 
	@encryptedrestorepassword = N''C1QDEImZ1ZqUULth6tzpVSmoGK58rQchprgQbO7fVKY='' 
	
IF(@ResultCode != 0)
	RAISERROR(''One or more operations failed to complete.'', 16, 1);
', 
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


