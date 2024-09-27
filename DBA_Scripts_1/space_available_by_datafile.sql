SELECT name AS 'File Name' , size/128 AS 'Total Size in MB',
size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0 AS 'Available Space In MB', 
max_size/128.0 AS 'Max File Size in MB', 
((size/128.00 -(size/128.0 - CAST(FILEPROPERTY(name, 'SpaceUsed') AS int)/128.0))/(max_size/128.0)* 100) AS 'Percent Full',
physical_name AS 'Physical Name'
FROM sys.database_files;

-- dbcc shrinkfile (preprod_pc_log, 51200) 

-- dbcc loginfo

-- exec [GWRE_IT].[dbo].[gwre_BackupDBLogs] preprod_pc,'\\WSFCNODE2\F$\MSSQL\LogBackups\','trn',1,'cloudopsdba@guidewire.com',0
