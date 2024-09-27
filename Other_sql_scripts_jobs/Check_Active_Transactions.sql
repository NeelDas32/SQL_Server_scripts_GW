USE [msdb]
GO

/****** Object:  Job [Check Active Transactions]    Script Date: 7/29/2024 11:50:13 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:50:13 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Check Active Transactions', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will generate a report of the active transactions on the server that have been connected for more than 8 hours.  It is scheduled to run 2 times a day at 9am & 5pm PST.  The report will be sent via email to the DBA group.  If there are no active transactions over half an hour, no email will be sent.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check for Active Transactions]    Script Date: 7/29/2024 11:50:13 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check for Active Transactions', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'/*****************************************************************
  Check for active transactions and send e-mail notification 
  to Database Administrators for determining dead connections 
  from the application servers to the user databases on the 
  production servers. Only send connections with a duration over 
  half an hour.  This job will be scheduled to run 2 times per day at 
  9:00am and 5:00pm PST.
  
  Author: S. Kratzer
  Date: 04/24/2013
********************************************************************/
-- Declare Variables
declare @rowcount int
declare @recipient_list varchar(200)
declare @message varchar(max)
declare @message_dtl varchar(max)
declare @e_subject varchar(200)
declare @textmsg varchar(60)

-- Set Default Values
set @rowcount = 0

-- Select data into Temporary Table
select d.name as Database_Name, e.host_name as Host_Name,
b.session_id as Session_Id, b.elapsed_time_seconds/60/60.00 as Elapsed_Time_Hours,
b.elapsed_time_seconds/60 as Elapsed_Time_Minutes, 
a.transaction_id as Transaction_Id
into #Active_Trans
from sys.dm_tran_database_transactions a
join sys.dm_tran_active_snapshot_database_transactions b
on b.transaction_id = a.transaction_id
join sys.databases d on a.database_id = d.database_id
join sys.dm_exec_sessions e on b.session_id = e.session_id
ORDER BY elapsed_time_seconds DESC;

-- Select data from Temporary Table
SELECT * from #Active_Trans

set @rowcount = @@ROWCOUNT

IF @rowcount > 0 
-- Fill message detail
SET @message_dtl = 
 N''<H4>Active Transactions Report For '' + @@ServerName + '' Generated: '' + convert(varchar(25), current_timestamp, 100) +''</H4>'' +
--    N''<table border="1"><FONT FACE="Arial, Helvetica, Geneva" SIZE="-2">'' + N''<th>Database_Name</th>'' +
    N''<table border="1"><tr>'' + N''<th>Database_Name</th>'' +
    N''<th>Host_Name</th><th>Session_Id</th><th>Elapsed_Time_Hours</th>'' +
    N''<th>Elapsed_Time_Minutes</th><th>Transaction_Id</th></tr>'' +
    CAST ( ( SELECT td = Database_Name, '''',
                td = Host_Name, '''',
	            td = Session_Id, '''',
                td = Elapsed_Time_Hours, '''',
                td = Elapsed_Time_Minutes, '''',
                td = Transaction_Id, ''''                
FROM #Active_Trans
WHERE Elapsed_Time_Minutes > 480
ORDER BY Elapsed_Time_Minutes DESC
FOR XML PATH(''tr''), TYPE ) AS NVARCHAR(MAX)) + N''</FONT></table>'';

-- If rows are returned, send notification e-mail
IF @rowcount > 0 and @message_dtl is not NULL
  BEGIN 
      SET @recipient_list = ''cloudopsdba@guidewire.com'' 
      SET @message = @message_dtl
      SET @e_subject =  ''Active Transactions over 8 hours found on: '' + @@servername 
      EXEC msdb..sp_send_dbmail @profile_name=''Amazon SES SMTP'', @recipients = @recipient_list , @body=@message, @subject=@e_subject, @body_format = ''HTML'';
  END

DROP TABLE #Active_Trans

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check Active Connections - 5pm', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150602, 
		@active_end_date=99991231, 
		@active_start_time=170100, 
		@active_end_time=235959, 
		@schedule_uid=N'a2df0df8-de8b-4bb3-9d43-fb44650d2dc5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Check Active Connections - 9am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20150602, 
		@active_end_date=99991231, 
		@active_start_time=90100, 
		@active_end_time=235959, 
		@schedule_uid=N'b5ee7f5a-6811-4d53-a91e-2b2e842ad256'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


