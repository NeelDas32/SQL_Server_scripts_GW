USE [master]
GO

/****** Object:  StoredProcedure [dbo].[create_and_grant_user]    Script Date: 7/30/2024 11:08:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[create_and_grant_user]
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
GO


