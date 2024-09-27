USE [msdb]
GO

/****** Object:  Job [CollectCPUUsageHistory]    Script Date: 7/29/2024 11:50:38 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:50:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CollectCPUUsageHistory', 
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
/****** Object:  Step [CollectCPUUsageHistory_1]    Script Date: 7/29/2024 11:50:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CollectCPUUsageHistory_1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'
/*****	Output: 
	SQLServer_CPU_Utilization: % CPU utilized from SQL Server Process
	System_Idle_Process: % CPU Idle - Not serving to any process 
	Other_Process_CPU_Utilization: % CPU utilized by processes otherthan SQL Server
	Event_Time: Time when these values captured
*****/

DECLARE @ts BIGINT;
DECLARE @lastNmin BIGINT;
SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
SET @lastNmin = 600;
SELECT @ts =(SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info); 
delete from GWRE_IT_NEW..CPUUsage
insert  into GWRE_IT_NEW..CPUUsage
SELECT TOP(@lastNmin)
		SQLProcessUtilization AS [SQLServer_CPU_Utilization], 
		SystemIdle AS [System_Idle_Process], 
		100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization], 
		DATEADD(ms,-1 *(@ts - [timestamp]),GETDATE())AS [Event_Time] 
FROM (SELECT record.value(''(./Record/@id)[1]'',''int'')AS record_id, 
record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]'',''int'')AS [SystemIdle], 
record.value(''(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]'',''int'')AS [SQLProcessUtilization], 
[timestamp]      
FROM (SELECT[timestamp], convert(xml, record) AS [record]             
FROM sys.dm_os_ring_buffers             
WHERE ring_buffer_type =N''RING_BUFFER_SCHEDULER_MONITOR''AND record LIKE''%%'')AS x )AS y 
ORDER BY record_id DESC; 
', 
		@database_name=N'GWRE_IT_NEW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220308, 
		@active_end_date=99991231, 
		@active_start_time=223000, 
		@active_end_time=235959, 
		@schedule_uid=N'52591cb9-0a7a-46dd-baf5-26a1f2a669e8'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


