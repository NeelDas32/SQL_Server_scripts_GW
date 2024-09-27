SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- ensure a USE <databasename> statement has been executed first.
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER OFF;
DECLARE @DBName varchar(50);
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @frag float;
DECLARE @command varchar(8000);
DECLARE @ERROR_MSG varchar(8000);
DECLARE @ERROR_NUM INT;

SET @DBName='preprod_pc' -- update with the database that still has outstanding indexes to rebuild in GWRE_IT.dbo.IndexFrag table

EXEC ('USE ['+@DBName+'];')

PRINT 'Processing Indexes for : ' + @DBName;

-- Declare the cursor for the list of partitions to be processed.
DECLARE partitions CURSOR FOR 
SELECT SCHEMA_NAME, TABLE_NAME, INDEX_NAME, FRAG 
FROM [GWRE_IT].[dbo].[IndexFrag]
WHERE DB_NAME = @DBName
and FRAG > 30 and PAGES > 300
and command is null
order by TABLE_NAME, INDEX_NAME

-- Open the cursor.
OPEN partitions;

-- Loop through the partitions.
FETCH NEXT
   FROM partitions
   INTO @schemaname, @objectname, @indexname, @frag;

WHILE @@FETCH_STATUS = 0
    BEGIN;
     SELECT @command = 'USE '+'['+@DBName+']; ALTER INDEX '+'['+ @indexname +'] ON [' + @schemaname + '].[' + @objectname + '] REBUILD WITH (ONLINE = ON (WAIT_AT_LOW_PRIORITY (MAX_DURATION = 5 MINUTES, ABORT_AFTER_WAIT = SELF)))';
	 EXEC (@command);
		
       PRINT 'Executed ' + @command;

       UPDATE [GWRE_IT].[dbo].[IndexFrag]
       SET COMMAND=@command, ERROR_NUM=ERROR_NUMBER(), ERROR_MSG=ERROR_MESSAGE() 
       WHERE DB_NAME=@DBName AND TABLE_NAME=@objectname AND INDEX_NAME=@indexname

       FETCH NEXT FROM partitions INTO @schemaname, @objectname, @indexname, @frag;
    END;

-- Close and deallocate the cursor.
CLOSE partitions;
DEALLOCATE partitions;


