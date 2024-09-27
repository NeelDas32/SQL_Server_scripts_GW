USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[gwre_UpdateStatistics]    Script Date: 7/30/2024 11:13:25 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[gwre_UpdateStatistics]
@P_DBName sysname
as

SET NOCOUNT ON;
SET QUOTED_IDENTIFIER OFF;
DECLARE @DBName varchar(50);
DECLARE @row_mod_threshold int;
DECLARE @name as varchar(255);
DECLARE @date datetime;
DECLARE @command varchar(8000);

SET @DBName=@P_DBName
SET @date=GETDATE()
SET @row_mod_threshold = 300;

-- set use Database 
EXEC ('USE ['+@DBName+'];')

PRINT 'Updating Statistics for Database : ' + @DBName;

DELETE FROM [GWRE_IT_NEW].[dbo].[UpdateStats] WHERE DB_NAME=@DBName
	  
-- Load the UpdateStats table
EXEC ('USE ['+@DBName+'];
      INSERT INTO [GWRE_IT_NEW].[dbo].[UpdateStats]
      SELECT '''+@date+''','''+@DBName+''', o.name  
      FROM sys.sysindexes i
      JOIN sysobjects o ON i.id=o.id
      WHERE indid=1 
      AND type = ''U''
      AND rowcnt <> 0
      AND rowmodctr <> 0
      AND (rowmodctr > '+@row_mod_threshold+')')
--      OR (rowmodctr*100/rows) >= 10.0 )')

-- Declare the cursor for statistics to be processed.
DECLARE stats_loop CURSOR FOR
SELECT TABLE_NAME 
FROM [GWRE_IT_NEW].[dbo].[UpdateStats]
WHERE DB_NAME = @DBName

-- Open the cursor
OPEN stats_loop

-- Loop through the cursor
FETCH NEXT 
FROM stats_loop
INTO @name

WHILE (@@FETCH_STATUS <> -1)
BEGIN;
    IF (@@FETCH_STATUS <> -2)
        PRINT 'Updating Statistics on table ' + @name
        SELECT @command = 'USE ['+@DBName+']; UPDATE STATISTICS [dbo].['+@name+'];';
    
        EXEC (@command);

FETCH NEXT FROM stats_loop INTO @name;

END;

-- Close and deallocate the cursor.
CLOSE stats_loop;

DEALLOCATE stats_loop;



GO


