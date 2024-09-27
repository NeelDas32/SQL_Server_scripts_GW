USE [msdb]
GO

/****** Object:  Job [Refresh i11 databases from OLDBACKUP]    Script Date: 7/29/2024 11:43:52 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:43:52 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Refresh i11 databases from OLDBACKUP', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job refreshes the i11 x-center databases production datbase backup after masking the data.                             Backups should be placed in the path \\10.150.0.28\h$\Preprod_maskedbackups after it is masked.                       The job will remove the replication from teh respective Claim center database and after restore it will shrink the log files to 50 GB. Transaction log backups will be disabled and enabled after the refresh automatically. Databases will be added to AOA after the refres', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Disable Backup Transactional Log Job]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable Backup Transactional Log Job', 
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
/****** Object:  Step [Disable SSIS Jobs -NI]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Disable SSIS Jobs -NI', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd  -S WSFCNODE1 -d msdb -Q "EXEC dbo.sp_update_job @job_name = N''NI_GWSAPIntegrationi11'',@enabled = 0"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set HADR off node2-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set HADR off node2-i11_ab', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_ab" -i "F:\SQLJobScripts\SetHADRoff.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from AoA-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from AoA-i11_ab', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER AVAILABILITY GROUP [PreProd] REMOVE DATABASE [i11_ab];
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from node2-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from node2-i11_ab', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_ab" -i "F:\SQLJobScripts\RemoveDBNode2.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections-i11_ab', 
		@step_id=6, 
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
WHERE p.dbid = db_id(''i11_ab'')

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
/****** Object:  Step [Restore database-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database-i11_ab', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE i11_ab SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

USE [master]
RESTORE DATABASE [i11_ab] FROM  DISK = ''F:\MSSQL\Backup\prod_unmasked_ab.bak'' WITH 
MOVE ''prod_unmasked_ab'' TO ''Y:\MSSQL\DATA\i11_ab.mdf'',  
MOVE ''prod_unmasked_ab_log'' TO ''E:\MSSQL\LOG\i11_ab_log.ldf'',  
NOUNLOAD, REPLACE,  STATS = 5
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adjust login and owner-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adjust login and owner-i11_ab', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Remove prod logins

use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''prod_ab'')
DROP USER [prod_ab];
GO



use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-FR-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-FR-RO-PROD-USERS];
GO

use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-ProdDB-RO'')
DROP USER [GWRE-CLOUD\ICARE-ProdDB-RO];
GO

use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SI-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-SI-RO-PROD-USERS];
GO


use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-UnmaskedDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-UnmaskedDb-RO];
GO

use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''icare_prod_ro_user'')
DROP USER [icare_prod_ro_user];
GO
use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''icare_unmasked_ro_user'')
DROP USER [icare_unmasked_ro_user];
GO
use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''gwre-cloud\icare-dhic-proddb-rw'')
DROP USER [gwre-cloud\icare-dhic-proddb-rw];
GO
use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''ICAREPROD\ds_jobserver'')
DROP USER [ICAREPROD\ds_jobserver];
GO
use [i11_ab]
go
IF EXISTS (SELECT name FROM i11_ab.dbo.sysusers WHERE name = ''test1'')
DROP USER [test1];
GO
-- Change DB owner

USE [i11_ab]
GO
EXEC dbo.sp_changedbowner @loginame = N''icarepreprod\sqlsa'', @map = false
GO

-- Replace application db_owner
use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''i11_ab'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''i11_ab'' )
       EXEC (''sp_grantdbaccess '' +  ''i11_ab'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''i11_ab'' )
go
exec sp_addrolemember ''db_owner'', ''i11_ab'';
go
ALTER USER i11_ab WITH DEFAULT_SCHEMA = [dbo];
go

use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''icare_i13_edw_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_edw_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_edw_user'';
go
ALTER USER icare_i13_edw_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_edw_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''icare_i13_qlik_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_qlik_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_qlik_user'';
go
ALTER USER icare_i13_qlik_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_qlik_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\AppD_DbMon'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\AppD_DbMon]'' )

go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\AppD_DbMon'';
go
ALTER USER [GWRE-CLOUD\AppD_DbMon] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-APOLLO-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-SE-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-SE-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_ab
go
IF EXISTS (SELECT ''X''
           FROM i11_ab.dbo.sysusers
                WHERE name = ''icarepreprod\ds_jobserver'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[icarepreprod\ds_jobserver]'')
       EXEC (''sp_grantdbaccess '' + ''[icarepreprod\ds_jobserver]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[icarepreprod\ds_jobserver]'' )
go
exec sp_addrolemember ''db_datareader'', ''icarepreprod\ds_jobserver'';
go
ALTER USER [icarepreprod\ds_jobserver] WITH DEFAULT_SCHEMA = [dbo];
go



', 
		@database_name=N'i11_ab', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set HADR off node2-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set HADR off node2-i11_cc', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_cc" -i "F:\SQLJobScripts\SetHADRoff.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from AoA-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from AoA-i11_cc', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER AVAILABILITY GROUP [Preprod] REMOVE DATABASE [i11_cc];
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from node2-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from node2-i11_cc', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_cc" -i "F:\SQLJobScripts\RemoveDBNode2.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove Replication-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove Replication-i11_cc', 
		@step_id=12, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use i11_cc
exec sp_subscription_cleanup @publisher = N''WSFCNODE1'', @publisher_db = N''i11_cc'', 
@publication = N''i11_ClaimCenterReporting''
go
use i11_cc
exec sp_dropsubscription @publication = N''i11_ClaimCenterReporting'', @subscriber = N''all'', 
@destination_db = N''REPORTDB.i11_cc_rpt'', @article = N''all''
go
-- Drop publication
exec sp_droppublication @publication = N''i11_ClaimCenterReporting''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections-i11_cc', 
		@step_id=13, 
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
WHERE p.dbid = db_id(''i11_cc'')

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
/****** Object:  Step [Restore database-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database-i11_cc', 
		@step_id=14, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE i11_cc SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

USE [master]
RESTORE DATABASE [i11_cc] FROM  DISK = ''F:\MSSQL\Backup\prod_unmasked_cc.bak'' WITH 
MOVE ''prod_unmasked_cc'' TO ''Y:\MSSQL\DATA\i11_cc.mdf'',  
MOVE ''prod_unmasked_cc_log'' TO ''E:\MSSQL\LOG\i11_cc_log.ldf'',  
NOUNLOAD, REPLACE,  STATS = 5
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adjust login and owner-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adjust login and owner-i11_cc', 
		@step_id=15, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Remove prod logins

use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''prod_cc'')
DROP USER [prod_cc];
GO



use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-FR-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-FR-RO-PROD-USERS];
GO

use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-ProdDB-RO'')
DROP USER [GWRE-CLOUD\ICARE-ProdDB-RO];
GO

use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SI-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-SI-RO-PROD-USERS];
GO


use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-UnmaskedDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-UnmaskedDb-RO];
GO

use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''icare_prod_ro_user'')
DROP USER [icare_prod_ro_user];
GO
use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''icare_unmasked_ro_user'')
DROP USER [icare_unmasked_ro_user];
GO
use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''gwre-cloud\icare-dhic-proddb-rw'')
DROP USER [gwre-cloud\icare-dhic-proddb-rw];
GO
use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''ICAREPROD\ds_jobserver'')
DROP USER [ICAREPROD\ds_jobserver];
GO
use [i11_cc]
go
IF EXISTS (SELECT name FROM i11_cc.dbo.sysusers WHERE name = ''test1'')
DROP USER [test1];
GO
-- Change DB owner

USE [i11_cc]
GO
EXEC dbo.sp_changedbowner @loginame = N''icarepreprod\sqlsa'', @map = false
GO

-- Replace application db_owner
use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''i11_cc'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''i11_cc'' )
       EXEC (''sp_grantdbaccess '' +  ''i11_cc'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''i11_cc'' )
go
exec sp_addrolemember ''db_owner'', ''i11_cc'';
go
ALTER USER i11_cc WITH DEFAULT_SCHEMA = [dbo];
go

use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''icare_i13_edw_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_edw_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_edw_user'';
go
ALTER USER icare_i13_edw_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_edw_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''icare_i13_qlik_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_qlik_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_qlik_user'';
go
ALTER USER icare_i13_qlik_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_qlik_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\AppD_DbMon'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\AppD_DbMon]'' )

go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\AppD_DbMon'';
go
ALTER USER [GWRE-CLOUD\AppD_DbMon] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-APOLLO-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-SE-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-SE-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_cc
go
IF EXISTS (SELECT ''X''
           FROM i11_cc.dbo.sysusers
                WHERE name = ''icarepreprod\ds_jobserver'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[icarepreprod\ds_jobserver]'')
       EXEC (''sp_grantdbaccess '' + ''[icarepreprod\ds_jobserver]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[icarepreprod\ds_jobserver]'' )
go
exec sp_addrolemember ''db_datareader'', ''icarepreprod\ds_jobserver'';
go
ALTER USER [icarepreprod\ds_jobserver] WITH DEFAULT_SCHEMA = [dbo];
go



', 
		@database_name=N'i11_cc', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set HADR off node2-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set HADR off node2-i11_bc', 
		@step_id=16, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_bc" -i "F:\SQLJobScripts\SetHADRoff.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from AoA-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from AoA-i11_bc', 
		@step_id=17, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER AVAILABILITY GROUP [Preprod] REMOVE DATABASE [i11_bc];
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from node2-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from node2-i11_bc', 
		@step_id=18, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_bc" -i "F:\SQLJobScripts\RemoveDBNode2.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections-i11_bc', 
		@step_id=19, 
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
WHERE p.dbid = db_id(''i11_bc'')

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
/****** Object:  Step [Restore database-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database-i11_bc', 
		@step_id=20, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE i11_bc SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

USE [master]
RESTORE DATABASE [i11_bc] FROM  DISK = ''F:\MSSQL\Backup\prod_unmasked_bc.bak'' WITH 
MOVE ''prod_unmasked_bc'' TO ''Y:\MSSQL\DATA\i11_bc.mdf'',  
MOVE ''prod_unmasked_bc_log'' TO ''E:\MSSQL\LOG\i11_bc_log.ldf'',  
NOUNLOAD, REPLACE,  STATS = 5
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adjust login and owner-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adjust login and owner-i11_bc', 
		@step_id=21, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Remove prod logins

use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''prod_bc'')
DROP USER [prod_bc];
GO



use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-FR-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-FR-RO-PROD-USERS];
GO

use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-ProdDB-RO'')
DROP USER [GWRE-CLOUD\ICARE-ProdDB-RO];
GO

use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SI-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-SI-RO-PROD-USERS];
GO


use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-UnmaskedDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-UnmaskedDb-RO];
GO

use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''icare_prod_ro_user'')
DROP USER [icare_prod_ro_user];
GO
use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''icare_unmasked_ro_user'')
DROP USER [icare_unmasked_ro_user];
GO
use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''gwre-cloud\icare-dhic-proddb-rw'')
DROP USER [gwre-cloud\icare-dhic-proddb-rw];
GO
use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''ICAREPROD\ds_jobserver'')
DROP USER [ICAREPROD\ds_jobserver];
GO
use [i11_bc]
go
IF EXISTS (SELECT name FROM i11_bc.dbo.sysusers WHERE name = ''test1'')
DROP USER [test1];
GO
-- Change DB owner

USE [i11_bc]
GO
EXEC dbo.sp_changedbowner @loginame = N''icarepreprod\sqlsa'', @map = false
GO

-- Replace application db_owner
use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''i11_bc'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''i11_bc'' )
       EXEC (''sp_grantdbaccess '' +  ''i11_bc'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''i11_bc'' )
go
exec sp_addrolemember ''db_owner'', ''i11_bc'';
go
ALTER USER i11_bc WITH DEFAULT_SCHEMA = [dbo];
go

use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''icare_i13_edw_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_edw_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_edw_user'';
go
ALTER USER icare_i13_edw_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_edw_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''icare_i13_qlik_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_qlik_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_qlik_user'';
go
ALTER USER icare_i13_qlik_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_qlik_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\AppD_DbMon'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\AppD_DbMon]'' )

go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\AppD_DbMon'';
go
ALTER USER [GWRE-CLOUD\AppD_DbMon] WITH DEFAULT_SCHEMA = [dbo];
go

/*
use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-APOLLO-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go
*/

use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-SE-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-SE-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_bc
go
IF EXISTS (SELECT ''X''
           FROM i11_bc.dbo.sysusers
                WHERE name = ''icarepreprod\ds_jobserver'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[icarepreprod\ds_jobserver]'')
       EXEC (''sp_grantdbaccess '' + ''[icarepreprod\ds_jobserver]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[icarepreprod\ds_jobserver]'' )
go
exec sp_addrolemember ''db_datareader'', ''icarepreprod\ds_jobserver'';
go
ALTER USER [icarepreprod\ds_jobserver] WITH DEFAULT_SCHEMA = [dbo];
go



', 
		@database_name=N'i11_bc', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set HADR off node2-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set HADR off node2-i11_pc', 
		@step_id=22, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_pc" -i "F:\SQLJobScripts\SetHADRoff.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from AoA-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from AoA-i11_pc', 
		@step_id=23, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER AVAILABILITY GROUP [Preprod] REMOVE DATABASE [i11_pc];
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Remove database from node2-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Remove database from node2-i11_pc', 
		@step_id=24, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_pc" -i "F:\SQLJobScripts\RemoveDBNode2.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Kill connections-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Kill connections-i11_pc', 
		@step_id=25, 
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
WHERE p.dbid = db_id(''i11_pc'')

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
/****** Object:  Step [Restore database-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore database-i11_pc', 
		@step_id=26, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
GO
ALTER DATABASE i11_pc SET OFFLINE WITH ROLLBACK IMMEDIATE
GO

USE [master]
RESTORE DATABASE [i11_pc] FROM  DISK = ''F:\MSSQL\Backup\prod_unmasked_pc.bak'' WITH 
MOVE ''prod_unmasked_pc'' TO ''Y:\MSSQL\DATA\i11_pc.mdf'',  
MOVE ''prod_unmasked_pc_log'' TO ''E:\MSSQL\LOG\i11_pc_log.ldf'',  
NOUNLOAD, REPLACE,  STATS = 5
GO
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Adjust login and owner-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Adjust login and owner-i11_pc', 
		@step_id=27, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--Remove prod logins

use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''prod_cc'')
DROP USER [prod_cc];
GO



use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-FR-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-FR-RO-PROD-USERS];
GO

use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-ProdDB-RO'')
DROP USER [GWRE-CLOUD\ICARE-ProdDB-RO];
GO

use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-SI-RO-PROD-USERS'')
DROP USER [GWRE-CLOUD\ICARE-SI-RO-PROD-USERS];
GO


use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''GWRE-CLOUD\ICARE-UnmaskedDb-RO'')
DROP USER [GWRE-CLOUD\ICARE-UnmaskedDb-RO];
GO

use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''icare_prod_ro_user'')
DROP USER [icare_prod_ro_user];
GO
use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''icare_unmasked_ro_user'')
DROP USER [icare_unmasked_ro_user];
GO
use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''gwre-cloud\icare-dhic-proddb-rw'')
DROP USER [gwre-cloud\icare-dhic-proddb-rw];
GO
use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''ICAREPROD\ds_jobserver'')
DROP USER [ICAREPROD\ds_jobserver];
GO
use [i11_pc]
go
IF EXISTS (SELECT name FROM i11_pc.dbo.sysusers WHERE name = ''test1'')
DROP USER [test1];
GO
-- Change DB owner

USE [i11_pc]
GO
EXEC dbo.sp_changedbowner @loginame = N''icarepreprod\sqlsa'', @map = false
GO

-- Replace application db_owner
use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''i11_pc'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''i11_pc'' )
       EXEC (''sp_grantdbaccess '' +  ''i11_pc'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''i11_pc'' )
go
exec sp_addrolemember ''db_owner'', ''i11_pc'';
go
ALTER USER i11_pc WITH DEFAULT_SCHEMA = [dbo];
go

use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''icare_i13_edw_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_edw_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_edw_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_edw_user'';
go
ALTER USER icare_i13_edw_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_edw_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''icare_i13_qlik_user'')
  BEGIN
       EXEC (''sp_revokedbaccess '' +  ''icare_i13_qlik_user'' )
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''icare_i13_qlik_user'' )
go
exec sp_addrolemember ''db_datareader'', ''icare_i13_qlik_user'';
go
ALTER USER icare_i13_qlik_user WITH DEFAULT_SCHEMA = [dbo];
go
ALTER USER [icare_i13_qlik_user] WITH DEFAULT_SCHEMA = [dbo];
go
use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\AppD_DbMon'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\AppD_DbMon]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\AppD_DbMon]'' )

go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\AppD_DbMon'';
go
ALTER USER [GWRE-CLOUD\AppD_DbMon] WITH DEFAULT_SCHEMA = [dbo];
go

/*
use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-APOLLO-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-APOLLO-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-APOLLO-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go
*/

use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\ICARE-SUPPORT-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\ICARE-SUPPORT-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\ICARE-SUPPORT-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''GWRE-CLOUD\GWRE-SE-RO-PROD'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
       EXEC (''sp_grantdbaccess '' + ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[GWRE-CLOUD\GWRE-SE-RO-PROD]'' )
go
exec sp_addrolemember ''db_datareader'', ''GWRE-CLOUD\GWRE-SE-RO-PROD'';
go
ALTER USER [GWRE-CLOUD\GWRE-SE-RO-PROD] WITH DEFAULT_SCHEMA = [dbo];
go

use i11_pc
go
IF EXISTS (SELECT ''X''
           FROM i11_pc.dbo.sysusers
                WHERE name = ''icarepreprod\ds_jobserver'')
  BEGIN
       EXEC (''sp_revokedbaccess '' + ''[icarepreprod\ds_jobserver]'')
       EXEC (''sp_grantdbaccess '' + ''[icarepreprod\ds_jobserver]'')
  END
  ELSE
       EXEC (''sp_grantdbaccess '' +  ''[icarepreprod\ds_jobserver]'' )
go
exec sp_addrolemember ''db_datareader'', ''icarepreprod\ds_jobserver'';
go
ALTER USER [icarepreprod\ds_jobserver] WITH DEFAULT_SCHEMA = [dbo];
go



', 
		@database_name=N'i11_pc', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add database to AoA-i11_ab]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add database to AoA-i11_ab', 
		@step_id=28, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_ab" -i "F:\SQLJobScripts\AddDBAoA.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add database to AOA-i11_cc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add database to AOA-i11_cc', 
		@step_id=29, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_cc" -i "F:\SQLJobScripts\AddDBAoA.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add databsae to AOA-i11_bc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add databsae to AOA-i11_bc', 
		@step_id=30, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_bc" -i "F:\SQLJobScripts\AddDBAoA.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Add database to AOA-i11_pc]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Add database to AOA-i11_pc', 
		@step_id=31, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd -v db_name="i11_pc" -i "F:\SQLJobScripts\AddDBAoA.sql"', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Shrink Log files]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Shrink Log files', 
		@step_id=32, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- This step will NOT work when you have not altered the logical filenames after retoring from production backups
-- The data and log filenames are currently prod_unmasked_xx when they should be i11_xx and i11_xx_log
USE [i11_ab]
DBCC SHRINKFILE (N''i11_ab_log'',51200)

USE [i11_cc]
DBCC SHRINKFILE (N''i11_cc_log'',51200)

USE [i11_bc]
DBCC SHRINKFILE (N''i11_bc_log'',51200)

USE [i11_pc]
DBCC SHRINKFILE (N''i11_pc_log'',51200)', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Enable Backup Transactional Log Job]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Enable Backup Transactional Log Job', 
		@step_id=33, 
		@cmdexec_success_code=0, 
		@on_success_action=4, 
		@on_success_step_id=34, 
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
/****** Object:  Step [Enable ssis jobs- NI]    Script Date: 7/29/2024 11:43:52 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Enable ssis jobs- NI', 
		@step_id=34, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'CmdExec', 
		@command=N'sqlcmd  -S WSFCNODE1 -d msdb -Q "EXEC dbo.sp_update_job @job_name = N''NI_GWSAPIntegrationi11'',@enabled = 1"', 
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


