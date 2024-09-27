if exists (select 1 from GWRE_IT.sys.tables where name like 'upliftedlogin_audit')
begin 
DROP table GWRE_IT.dbo.upliftedlogin_audit 
end
create table GWRE_IT.dbo.upliftedlogin_audit 

( ID int identity(1,1),
  login_name varchar(30),
  create_date date,
  locked int default 0 ,
  last_locked date ,
  ran_by varchar(30)
)
------------------------------------------
if exists (select 1 from master.sys.procedures where name like 'create_and_grant_user')
begin 
DROP PROCEDURE dbo.create_and_grant_user
end
go
CREATE PROCEDURE dbo.create_and_grant_user
(
    @v_executor_username VARCHAR(30) NULL

)
AS
BEGIN

   declare @v_new_username VARCHAR(30) 
    declare @v_password VARCHAR(20) 
    declare  @v_user_count int 
    declare @v_sql VARCHAR(max) 
DECLARE @char CHAR = ''
DECLARE @charI INT = 0
DECLARE @password VARCHAR(100) = ''
DECLARE @len INT = 12 -- Length of Password
WHILE @len > 0
BEGIN
SET @charI = ROUND(RAND()*100,0)
SET @char = CHAR(@charI)
IF @charI > 48 AND @charI < 122
BEGIN
SET @password += @char
SET @len = @len - 1
END
END
    -- Get the current executor's username
   if @v_executor_username IS NULL  
    begin
      set @v_executor_username = user_name()
	 end
     
    -- Generate a random password
	if @v_password IS NULL  
      set @v_password = @password

    -- Create the username with _UPLIFTED suffix
   set  @v_new_username = @v_executor_username + 'DBA';
    -- Check if the user already exists
	
     
    SELECT @v_user_count = COUNT(*)   FROM sys.syslogins WHERE name = @v_new_username;
    IF @v_user_count > 0 
	  begin
        -- Change password and unlock the account
        set @v_sql  =  'ALTER LOGIN ' + @v_new_username + ' with password = ''' + @v_password + '''  unlock';
        exec  (@v_sql)
		exec ('ALTER LOGIN ' + @v_new_username + ' Enable')
		insert into GWRE_IT.dbo.upliftedlogin_audit values (@v_new_username,getdate(),0,null,SUSER_NAME())
		end
    ELSE
	  begin
        -- Create the user
        exec  ('CREATE LOGIN ' + @v_new_username + ' with password = ''' + @v_password + '''')
		exec  ('EXEC master..sp_addsrvrolemember @loginame = N'''+ @v_new_username +''', @rolename = N''sysadmin''')
        insert into GWRE_IT.dbo.upliftedlogin_audit values (@v_new_username,getdate(),0,null,SUSER_NAME())
      end  
		-- Grant DBA privileges
   
     
    -- Report the password to the user
    print('User ' + @v_new_username +' created with DBA privileges.');
    print('Password: '+ @v_password);

END
--------------------------------------------------------------------------------------------------

USE [msdb]
GO

/****** Object:  Job [Upliftedlogin]    Script Date: 12/13/2023 6:02:20 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 12/13/2023 6:02:20 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Upliftedlogin', 
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
/****** Object:  Step [login_disable_3days]    Script Date: 12/13/2023 6:02:21 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'login_disable_3days', 
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
DECLARE @name VARCHAR(50) -- database name 
DECLARE @ID int 
DECLARE db_cursor CURSOR FOR 
SELECT id, login_name 
FROM GWRE_IT.dbo.upliftedlogin_audit 
WHERE locked = 0 
and create_date <= cast (dateadd(dd,-3,GETDATE()) as date)
OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @ID,@name  
WHILE @@FETCH_STATUS = 0  
BEGIN
 EXEC(''Alter login '' + @name + '' DISABLE'')
 UPDATE GWRE_IT.dbo.upliftedlogin_audit
 SET locked = 1 , last_locked = getdate()
 FETCH NEXT FROM db_cursor INTO @name 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor
', 
		@database_name=N'master', 
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
		@active_start_date=20231213, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'26549cdb-1046-430a-99b8-aa456e0cd63a'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO




----------------
