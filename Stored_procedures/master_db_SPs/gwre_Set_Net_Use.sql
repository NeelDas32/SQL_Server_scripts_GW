USE [master]
GO

/****** Object:  StoredProcedure [dbo].[gwre_Set_Net_Use]    Script Date: 7/30/2024 11:05:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[gwre_Set_Net_Use] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('Logs - Start',getdate(),USER_NAME())
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('exec xp_cmdshell ''net use''',getdate(),USER_NAME())
-- Check the net use mapping
exec xp_cmdshell 'net use'
waitfor delay  '00:00:10'
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('exec xp_cmdshell ''net use B: /delete''',getdate(),USER_NAME())
-- If B exist, drop it so it can be recreated
exec xp_cmdshell 'net use B: /delete'
waitfor delay  '00:00:10'
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('exec xp_cmdshell ''net use B: \\10.150.0.101\H$ S75myV7vGDwwggKJ /User:GWRE-CLOUD\icare-backup-user /PERSISTENT:yes''',getdate(),USER_NAME())
-- recreate the mapping to the au1-bkp01 server
exec xp_cmdshell 'net use B: \\10.150.0.101\H$ S75myV7vGDwwggKJ /User:GWRE-CLOUD\icare-backup-user /PERSISTENT:yes'
waitfor delay  '00:00:10'
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('exec xp_cmdshell ''net use''',getdate(),USER_NAME())
exec xp_cmdshell 'net use' 
waitfor delay '00:00:10'
insert into  [GWRE_IT].[dbo].[check_netuse_output] values ('Logs - END',getdate(),USER_NAME())
END



GO


