--- YOU MUST EXECUTE THE FOLLOWING SCRIPT IN SQLCMD MODE.
:Connect WSFCNODE1
USE [master]
GO
--ALTER AVAILABILITY GROUP [PreProd] ADD DATABASE [SSISDB];
GO
:Connect WSFCNODE1
BACKUP DATABASE [SSISDB] TO  DISK = N'\\WSFCNODE1\Replica\SSISDB.bak' WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO
:Connect WSFCNODE2
RESTORE DATABASE [SSISDB] FROM  DISK = N'\\WSFCNODE1\Replica\SSISDB.bak' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5
GO
:Connect WSFCNODE1
BACKUP LOG [SSISDB] TO  DISK = N'\\WSFCNODE1\Replica\SSISDB.trn' WITH NOFORMAT, INIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5
GO
:Connect WSFCNODE2
RESTORE LOG [SSISDB] FROM  DISK = N'\\WSFCNODE1\Replica\SSISDB.trn' WITH  NORECOVERY,  NOUNLOAD,  STATS = 5
GO
:Connect WSFCNODE2
ALTER DATABASE [SSISDB] SET HADR AVAILABILITY GROUP = [PreProd];
GO
GO


