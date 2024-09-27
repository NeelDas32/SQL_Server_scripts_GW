-----------
:connect wsfcnode2 
ALTER DATABASE [SSISDB] SET HADR OFF;
GO

:connect wsfcnode2  	
EXEC msdb.dbo.sp_delete_database_backuphistory @database_name = N'SSISDB'
GO
USE [master]
GO
DROP DATABASE [SSISDB]
GO
-----------


----------------------------
