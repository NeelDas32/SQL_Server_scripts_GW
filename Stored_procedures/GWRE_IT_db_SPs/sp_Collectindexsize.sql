USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[sp_Collectindexsize]    Script Date: 7/30/2024 11:13:47 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_Collectindexsize] 
as 
SET NOCOUNT ON;

DECLARE @Database TABLE (DbName SYSNAME);
DECLARE @IndexStats TABLE (
	ServerName SYSNAME
	,DbName SYSNAME
	,SchemaName SYSNAME
	,TableName SYSNAME
	,IndexId INT
	,IndexType VARCHAR(12)
	,IndexName SYSNAME
	,IndexSizeMb INT
	,ReportDate DATETIME
	);
DECLARE @DbName AS SYSNAME;
DECLARE @Sql AS VARCHAR(MAX);

SET @DbName = '';

INSERT INTO @Database (DbName)
SELECT NAME
FROM sys.databases
WHERE NAME  IN (
		'preprod_cc',
		'preprod_bc',
		'preprod_pc',
		'preprod_ab'
				)
	AND state_desc = 'ONLINE'
ORDER BY NAME ASC;

WHILE @DbName IS NOT NULL
BEGIN
	SET @DbName = (
			SELECT MIN(DbName)
			FROM @Database
			WHERE DbName > @DbName
			);
	SET @Sql = 'USE ' + QUOTENAME(@DbName) + ';	
	SELECT @@ServerName AS ServerName
	,''' + @DbName + ''' AS ''DbName'' 
	,OBJECT_SCHEMA_NAME(i.OBJECT_ID) AS SchemaName
	,OBJECT_NAME(i.OBJECT_ID) AS TableName
	,i.index_id AS IndexId
	,CASE WHEN i.index_id > 1 THEN ''Nonclustered'' WHEN i.index_id = 1 THEN ''Clustered'' ELSE ''Heap'' END AS IndexType
	,CASE WHEN i.NAME IS NULL THEN ''No Name'' ELSE i.Name END AS IndexName
	,(8 * SUM(a.used_pages)/1024) AS ''IndexSizeMb''
	,getdate() as ''ReportDate''
FROM sys.indexes AS i
JOIN sys.partitions AS p ON p.OBJECT_ID = i.OBJECT_ID
	AND p.index_id = i.index_id
JOIN sys.allocation_units AS a ON a.container_id = p.partition_id
WHERE a.used_pages > 0
GROUP BY i.OBJECT_ID
	,i.index_id
	,i.NAME
ORDER BY IndexSizeMb DESC; 
'

	INSERT INTO @IndexStats
	EXEC (@Sql);
END


INSERT INTO  GWRE_IT_NEW..CollectIndexSize
SELECT ServerName
	,DbName
	,SchemaName
	,TableName
	,IndexId
	,IndexType
	,IndexName
	,IndexSizeMb
	,ReportDate 
FROM @IndexStats
--WHERE IndexType = 'Nonclustered'
--AND IndexSizeMb > 0
--ORDER BY IndexSizeMb DESC;



GO


