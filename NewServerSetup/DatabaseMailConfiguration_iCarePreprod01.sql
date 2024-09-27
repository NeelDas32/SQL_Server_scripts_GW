--------------------------------------------------------------------------------------------------------------------
--  Database Mail Simple Configuration Template.
--
--  This template enables Database Mail and creates a Database Mail profile, an SMTP account and associates the account to the profile.
--  Uses sysmail_add_account_sp, msdb.dbo.sysmail_add_profile_sp and msdb.dbo.sysmail_add_profileaccount_sp
--  Uses msdb.dbo.sysmail_add_principalprofile_sp to set the profile to the default public profile for all users.
--  Perform search and replace the database server name and save file under new name on the server before executing.
--------------------------------------------------------------------------------------------------------------------
-- Replace Amazon SES SMTP with an actual server name - 11 occurrances

-- Enable Database mail on the server
sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Database Mail XPs', 1;
GO
RECONFIGURE
GO

-- Declare variables
DECLARE @profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
        @replyto_address NVARCHAR(128),
        @description NVARCHAR(128),
        @display_name NVARCHAR(128),
	@port_num int,
        @enable_ssl int;

-- Profile name. Replace with the name for your profile
        SET @profile_name = 'Amazon SES SMTP';

-- Account information. Replace with the information for your account.
        SET @account_name = 'Amazon SES';
        SET @SMTP_servername = 'email-smtp.us-west-2.amazonaws.com';
        SET @email_address = 'cloudopsalerts@guidewire.com';
        SET @replyto_address = 'noreply@icare-preprod-wsfcnode1.com';
        SET @display_name = 'noreply@icare-preprod-wsfcnode1.com';
	SET @port_num = 587;
        SET @description = '';

-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  RAISERROR('The specified Database Mail profile (Amazon SES SMTP) already exists.', 16, 1);
  GOTO done;
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
 RAISERROR('The specified Database Mail account (Amazon SES SMTP) already exists.', 16, 1) ;
 GOTO done;
END;

-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @email_address = @email_address,
    @display_name = @display_name,
    @replyto_address = @replyto_address,
    @description = @description,
    @mailserver_name = @SMTP_servername,
    @port = @port_num,
    @enable_ssl = 0;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail account (Amazon SES SMTP).', 16, 1) ;
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name,
    @description = @description ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile (Amazon SES SMTP).', 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the specified profile with the specified account (Amazon SES SMTP).', 16, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Set the profile to the default public profile.
EXECUTE @rv=msdb.dbo.sysmail_add_principalprofile_sp
    @principal_name = 'public',
    @profile_name = @profile_name,
    @is_default = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to set the specified profile to the default public profile (Amazon SES SMTP).', 16, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;

done:

GO