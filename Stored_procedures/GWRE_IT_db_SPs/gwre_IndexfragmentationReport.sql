USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[gwre_IndexfragmentationReport]    Script Date: 7/30/2024 11:13:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE procedure [dbo].[gwre_IndexfragmentationReport] 
@P_DBName sysname
as

-- ensure a USE <databasename> statement has been executed first.
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER OFF;
DECLARE @DBName varchar(50);
DECLARE @DB_ID int;
DECLARE @schemaname sysname;
DECLARE @objectname sysname;
DECLARE @indexname sysname;
DECLARE @frag float;
DECLARE @command varchar(8000);
DECLARE @date datetime;
DECLARE @ERROR_MSG varchar(8000);
DECLARE @ERROR_NUM INT


SET @DBName=@P_DBName
SET @date=GETDATE()

EXEC ('USE ['+@DBName+'];')

PRINT 'Processing Indexes for : ' + @DBName;

SELECT @DB_ID=database_ID from sys.databases where name=@DBName
DELETE from [GWRE_IT_NEW].[dbo].[IndexFragReport] where DB_NAME=@DBName
	  
-- Load the IndexFrag table
EXEC ('USE ['+@DBName+'];
      INSERT INTO [GWRE_IT_NEW].[dbo].[IndexFragReport]
      SELECT '''+@date+''','''+@DBName+''', TABLE_SCHEMA,object_name(F.object_id) OBJ,I.name IND,
      F.avg_fragmentation_in_percent,
      F.page_count, 
      CASE WHEN I.allow_row_locks=1 THEN ''ON''
      ELSE ''OFF''
      END as ALLOWROWSLOCKS, 
      CASE WHEN I.allow_page_locks=1 THEN ''ON''
      ELSE ''OFF''
      END AS ALLOWPAGELOCKS, 
      CASE WHEN I.fill_factor=0 THEN 100 ELSE I.fill_factor END as FILL_FACTOR, NULL, NULL, NULL
      FROM sys.dm_db_index_physical_stats ('+@DB_ID+',NULL,NULL,NULL,NULL) F
      JOIN sys.indexes I
      ON(F.object_id=I.object_id) AND I.index_id=F.index_id
      JOIN INFORMATION_SCHEMA.TABLES S
      ON (S.TABLE_NAME=OBJECT_NAME(F.object_id))
      WHERE I.index_id <> 0
	  AND I.type_desc <> ''SPATIAL''
      AND F.database_id='+@DB_ID+'
      AND S.TABLE_SCHEMA = ''dbo''
      AND OBJECTPROPERTY(I.object_id,''ISSYSTEMTABLE'')=0 
	  AND F.avg_fragmentation_in_percent >= 30.0 and F.page_count>300
	  order by I.name'
      )



GO


