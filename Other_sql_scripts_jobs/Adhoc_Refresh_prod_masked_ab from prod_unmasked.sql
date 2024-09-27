USE [msdb]
GO

/****** Object:  Job [Adhoc_Refresh_prod_masked_ab from prod_unmasked]    Script Date: 7/29/2024 11:46:21 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:46:21 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Adhoc_Refresh_prod_masked_ab from prod_unmasked', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup database prod_unmasked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup database prod_unmasked_ab', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [prod_unmasked_ab] TO DISK = N''F:\MSSQL\Backup\prod_unmasked_ab.bak''  WITH NOFORMAT, INIT,  NAME = N''prod_unmasked_ab-Full Datpcase Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Restore Database-prod_masked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Restore Database-prod_masked_ab', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master]
RESTORE DATABASE [prod_masked_ab] FROM  DISK = N''F:\MSSQL\Backup\prod_unmasked_ab.bak'' WITH  FILE = 1, 
 MOVE N''prod_unmasked_ab'' TO N''D:\MSSQL\DATA\prod_masked_ab.mdf'', 
  MOVE N''prod_unmasked_ab_log'' TO N''E:\MSSQL\LOG\prod_masked_ab_log.ldf'',  NOUNLOAD,  STATS = 5
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run masking scripts-prod_masked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run masking scripts-prod_masked_ab', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use prod_masked_ab
go

SET ANSI_NULLS, QUOTED_IDENTIFIER ON;
go

UPDATE ab_abcontact SET FormerName = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',FormerName),2),1,LEN(FormerName)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET Name = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',Name),2),1,LEN(Name)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET NameDenorm = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',NameDenorm),2),1,LEN(NameDenorm)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET TradingName_icare = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',TradingName_icare),2),1,LEN(TradingName_icare)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET WorkPhone = ''099999999'' WHERE WorkPhone IS NOT NULL AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET MiddleName = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',MiddleName),2),1,LEN(MiddleName)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET EmailAddress2 = substring(convert(varchar(max), hashbytes(''SHA2_256'',SUBSTRING(EmailAddress2 ,1,CHARINDEX(''@'',EmailAddress2 )-1)),2),1,10)+ ''@test.icare.nsw.gov.au''      WHERE EmailAddress2 <> '''' AND EmailAddress2 <> ''NULL'' AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET HomePhone = ''099999999'' WHERE HomePhone IS NOT NULL AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET LastName = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',LastName),2),1,LEN(LastName)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET TrusteeName_icare = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',TrusteeName_icare),2),1,LEN(TrusteeName_icare)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET TrustName_icare = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',TrustName_icare),2),1,LEN(TrustName_icare)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET FaxPhone = ''099999999'' WHERE FaxPhone IS NOT NULL AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET EmailAddress1 = substring(convert(varchar(max), hashbytes(''SHA2_256'',SUBSTRING(EmailAddress1 ,1,CHARINDEX(''@'',EmailAddress1 )-1)),2),1,10)+ ''@test.icare.nsw.gov.au''      WHERE EmailAddress1 <> '''' AND EmailAddress1 <> ''NULL'' AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET CellPhone = ''099999999'' WHERE CellPhone IS NOT NULL AND Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET FirstName = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',FirstName),2),1,LEN(FirstName)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET FirstNameDenorm = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',FirstNameDenorm),2),1,LEN(FirstNameDenorm)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_abcontact SET LastNameDenorm = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',LastNameDenorm),2),1,LEN(LastNameDenorm)) WHERE Subtype in (select ID from abtl_abcontact where TYPECODE not in ( ''ABPersonVendor'', ''ABCompanyVendor''))
UPDATE ab_address SET AddressLine2 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',AddressLine2),2),1,LEN(AddressLine2)) WHERE ID in (select a.PrimaryAddressID as AddressID         from ab_abcontact a          inner join abtl_abcontact b on a.Subtype = b.ID          where b.TYPECODE in (''ABPerson'', ''ABCompany'')        union        select c.AddressID        from ab_abcontact a         inner join abtl_abcontact b on a.Subtype = b.ID          inner join ab_abcontactaddress c on c.ContactID = a.ID         where b.TYPECODE in (''ABPerson'', ''ABCompany''))
UPDATE ab_address SET AddressLine1 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',AddressLine1),2),1,LEN(AddressLine1)) WHERE ID in (select a.PrimaryAddressID as AddressID         from ab_abcontact a          inner join abtl_abcontact b on a.Subtype = b.ID          where b.TYPECODE in (''ABPerson'', ''ABCompany'')        union        select c.AddressID        from ab_abcontact a         inner join abtl_abcontact b on a.Subtype = b.ID          inner join ab_abcontactaddress c on c.ContactID = a.ID         where b.TYPECODE in (''ABPerson'', ''ABCompany''))
UPDATE ab_address SET AddressLine3 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',AddressLine3),2),1,LEN(AddressLine3)) WHERE ID in (select a.PrimaryAddressID as AddressID         from ab_abcontact a          inner join abtl_abcontact b on a.Subtype = b.ID          where b.TYPECODE in (''ABPerson'', ''ABCompany'')        union        select c.AddressID        from ab_abcontact a         inner join abtl_abcontact b on a.Subtype = b.ID          inner join ab_abcontactaddress c on c.ContactID = a.ID         where b.TYPECODE in (''ABPerson'', ''ABCompany''))
UPDATE ab_addresscorrection SET CorrectedAddressLine1 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',CorrectedAddressLine1),2),1,LEN(CorrectedAddressLine1))
UPDATE ab_addresscorrection SET AddressLine1 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',AddressLine1),2),1,LEN(AddressLine1))
UPDATE ab_addresscorrection SET AddressLine2 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',AddressLine2),2),1,LEN(AddressLine2))
UPDATE ab_addresscorrection SET CorrectedAddressLine2 = SUBSTRING(CONVERT(VARCHAR(MAX),HASHBYTES(''SHA2_256'',CorrectedAddressLine2),2),1,LEN(CorrectedAddressLine2))
UPDATE ab_contact SET EmailAddress2 = substring(convert(varchar(max), hashbytes(''SHA2_256'',SUBSTRING(EmailAddress2 ,1,CHARINDEX(''@'',EmailAddress2 )-1)),2),1,10)+ ''@test.icare.nsw.gov.au''      WHERE EmailAddress2 <> '''' AND EmailAddress2 <> ''NULL'' AND ID not in (select contactID from ab_user)
UPDATE ab_contact SET EmailAddress1 = substring(convert(varchar(max), hashbytes(''SHA2_256'',SUBSTRING(EmailAddress1 ,1,CHARINDEX(''@'',EmailAddress1 )-1)),2),1,10)+ ''@test.icare.nsw.gov.au''      WHERE EmailAddress1 <> '''' AND EmailAddress1 <> ''NULL'' AND ID not in (select contactID from ab_user)
UPDATE a  SET BankAccountNumber = Masked_BankAccountNumber      FROM ab_eftdata a       INNER JOIN (select ID, RIGHT(''0000000000000'' +  CONVERT(VARCHAR(20), ROW_NUMBER() over (order by BankAccountNumber)),10)  as Masked_BankAccountNumber FROM ab_eftdata WHERE BankAccountNumber <> '''' AND BankAccountNumber is not null) maskedData ON a.ID = maskedData.ID
UPDATE ab_abcontact
SET DateOfBirth  = CASE WHEN DATEPART(quarter, cast(DateOfBirth as date)) = 1 THEN cast(year( cast(DateOfBirth as date)) as varchar) + ''-02-01''
                             WHEN DATEPART(quarter, cast(DateOfBirth as date)) = 2 THEN cast(year( cast(DateOfBirth as date)) as varchar) + ''-05-01''
                             WHEN DATEPART(quarter, cast(DateOfBirth as date)) = 3 THEN cast(year( cast(DateOfBirth as date)) as varchar) + ''-08-01''
                             WHEN DATEPART(quarter, cast(DateOfBirth as date)) = 4 THEN cast(year( cast(DateOfBirth as date)) as varchar) + ''-11-01'' END
where DateOfBirth is not null

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Refresh Prod_masked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Refresh Prod_masked_ab', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'use prod_masked_ab
go

  DECLARE @NAME VARCHAR(30) = DB_NAME();

  DELETE FROM [dbo].[abx_propertychange_icare]

  DELETE FROM [dbo].[abx_property_psc]
  
  DELETE FROM [dbo].[ab_message]
  
  UPDATE [dbo].[ab_credential] SET Password = ''PPNxQmp1UdWbZrn2G1Tj8+w01rI='' WHERE username = ''su''

  UPDATE [dbo].[ab_credential] SET Password = ''nWycZDYebsz6659TRS/W9mk65W0='' WHERE username = ''UnrestrictedUser''
  
  UPDATE [dbo].[ab_credential] SET username = ''datamigrationuser'' where username = ''DataMigration''
  
  UPDATE [dbo].[ab_credential] SET Password = ''xyRYdxyGvPOuivL3Yi4CSzTpoJg='' where username = ''IntegrationUser'' or username = ''datamigrationuser''

  UPDATE [dbo].[ab_user]
	SET [Retired] = [dbo].[ab_user].ID
	FROM [ab_user] INNER JOIN [ab_credential] on [ab_user].CredentialID = [ab_credential].ID
	WHERE [ab_credential].UserName not in (''BatchUser'',''ClientAppBC'',''ClientAppCC'',''ClientAppPC'',''datamigrationuser'',''defaultowner'',''IntegOktaUser'',''IntegrationUser'',''lighttouchdocuser'',''pu'',''su'',''sys'',''UnrestrictedUser'',''admin'')

  UPDATE [dbo].[ab_credential]
	SET Retired = [dbo].[ab_credential].ID
	WHERE [ab_credential].UserName not in (''BatchUser'',''ClientAppBC'',''ClientAppCC'',''ClientAppPC'',''datamigrationuser'',''defaultowner'',''IntegOktaUser'',''IntegrationUser'',''lighttouchdocuser'',''pu'',''su'',''sys'',''UnrestrictedUser'',''admin'')
	
  /*** Script to make sure default users are active and not locked. ***/
  UPDATE [dbo].[ab_credential]
	SET Active = 1, LockDate = null
	WHERE [ab_credential].UserName in (''BatchUser'',''ClientAppBC'',''ClientAppCC'',''ClientAppPC'',''datamigrationuser'',''defaultowner'',''IntegOktaUser'',''IntegrationUser'',
	''lighttouchdocuser'',''pu'',''su'',''sys'',''UnrestrictedUser'',''admin'')
	AND Retired = 0 
   
  IF @NAME NOT IN (''sit13_ab'', ''preprod_ab'') 
	UPDATE [dbo].[ab_systemparameter] SET [Value] = ''false'' WHERE Name = ''ProductionMode'' 
  ELSE
	UPDATE [dbo].[ab_systemparameter] SET [Value] = ''true'' WHERE Name = ''ProductionMode'' 
  ', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Backup database -prod_masked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Backup database -prod_masked_ab', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [prod_masked_ab] TO  DISK = N''\\10.150.0.101\h$\Preprod_maskedbackups\prod_masked_ab.bak'' WITH NOFORMAT, INIT,  NAME = N''prod_masked_ab-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [drop database prod_masked_ab]    Script Date: 7/29/2024 11:46:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'drop database prod_masked_ab', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'drop database prod_masked_ab', 
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


