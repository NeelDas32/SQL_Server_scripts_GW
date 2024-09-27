use master 
go

-- Step1
-- Start with doing a transaction log backup of the database 

-- Step2
use DBname -- replace with the actual database name
go
DBCC SHRINKFILE (N'DBname_log', 0, TRUNCATEONLY);  -- replace with the logs virtual file name
GO

-- Step 3
-- check to see how many VLFs are there now
dbcc LogInfo -- will return a row for each VLF

-- Step 4 
-- If more than 4 VLFs, you may need to repeat steps 1-3

-- Once you have 4 or less VLFs remaining (log file at initial size of when the database was created or 0)

-- For large production databases
ALTER DATABASE DBname  -- replace with the actual database name
 MODIFY FILE 
 ( 
       NAME = 'DBname_log' -- replace with the logs virtual file name
     , SIZE = 8192MB
     , FILEGROWTH = 8000MB
     , MAXSIZE = 102400MB -- set to the max size of your current log file
) 

-- After the alter, manually grow the log file 8000 MB at a time until the log file is the size it was originally.


-- For medium perf databases
ALTER DATABASE DBname  -- replace with the actual database name
 MODIFY FILE 
 ( 
       NAME = 'DBname_log' -- replace with the logs virtual file name
     , SIZE = 4096MB
     , FILEGROWTH = 4000MB
     , MAXSIZE = 51200MB -- set to the max size of your current log file
) 

-- After the alter, manually grow the log file 4000 MB at a time until the log file is the size it was originally.


-- For small development databases
ALTER DATABASE DBname  -- replace with the actual database name
 MODIFY FILE 
 ( 
       NAME = 'DBname_log' -- replace with the logs virtual file name
     , SIZE = 1024MB
     , FILEGROWTH = 1000MB
     , MAXSIZE = 25600MB -- set to the max size of your current log file
) 

-- After the alter, manually grow the log file 1000 MB at a time until the log file is the size it was originally.
