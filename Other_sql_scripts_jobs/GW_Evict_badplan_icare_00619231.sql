USE [msdb]
GO

/****** Object:  Job [GW_Evict_badplan_icare_00619231]    Script Date: 7/29/2024 11:56:38 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:56:38 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'GW_Evict_badplan_icare_00619231', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'GW_Evict_badplan_icare_00619231', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ICAREPREPROD\sqlsa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Capture_plan]    Script Date: 7/29/2024 11:56:38 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Capture_plan', 
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
DECLARE @plan_handle varbinary(64)
DECLARE @query_hash binary(8) 
DECLARE @query_plan_hash binary(8) 
DECLARE @eviction_Date datetime
DECLARE @execution_start_time datetime
DECLARE @database_id int = NULL
DECLARE @context_info VARCHAR(256) = NULL
DECLARE @cpu_time bigint = NULL
DECLARE @row_count int = NULL
DECLARE @Date datetime







SELECT @Date = getdate()

DECLARE db_cursor CURSOR FOR 
select plan_handle, query_plan_hash ,query_hash, last_execution_time --, database_id,context_info,cpu_time,row_count
from sys.dm_exec_query_stats r
where Query_Plan_Hash=0x200C2ADB4E6CBF09

OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @plan_handle, @query_plan_hash, @query_hash,@execution_start_time--,@database_id,@context_info,@cpu_time,@row_count

WHILE @@FETCH_STATUS = 0  
BEGIN  
insert into GWRE_IT.dbo.icare_00619231_bad_plan_evictions values (@plan_handle, @query_plan_hash, @query_hash,@Date, @execution_start_time) --,@database_id,@context_info,@cpu_time,@row_count)
DBCC FREEPROCCACHE (@plan_handle);   

FETCH NEXT FROM db_cursor INTO @plan_handle, @query_plan_hash, @query_hash, @execution_start_time --,@database_id,@context_info,@cpu_time,@row_count
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 

', 
		@database_name=N'GWRE_IT', 
		@output_file_name=N'F:\SQLJobLogs\freeup_bad_plan.txt', 
		@flags=2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 10 sec', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=10, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220201, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'70dbae7e-6fff-4c92-a310-67aaccb6f6cc'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


