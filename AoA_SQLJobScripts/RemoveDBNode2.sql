:connect wsfcnode2  	
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'$(db_name)'
GO
USE [master]
GO
DROP DATABASE [$(db_name)]
GO