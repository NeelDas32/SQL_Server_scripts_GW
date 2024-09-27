-- In the master database on the server, execute the below command
-- First replace Dest_DB_Name with your destination Database name
-- You will also need to replace DB_Name_Data and DB_Name_Log with the logical file names from the original database
-- And the drive paths for the backup file as well as the paths to be where you actually want the physical files 
-- to be created on the server.  Uncomment the Replace command if the Destination database already exist on the server.

RESTORE DATABASE [Dest_DB_Name] 
FROM DISK =  'C:\Temp\DB_Name.bkp' 
WITH  MOVE N'DB_Name_Data' TO N'F:\Data\Dest_DB_Name_Data.mdf' 
, MOVE N'DB_Name_Log' TO N'E:\Log\Dest_DB_Name_log.ldf'
--,REPLACE
