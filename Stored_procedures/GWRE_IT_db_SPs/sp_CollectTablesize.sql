USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[sp_CollectTablesize]    Script Date: 7/30/2024 11:13:52 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[sp_CollectTablesize]
as 
IF OBJECT_ID('tempdb.dbo.#space') IS NOT NULL
    DROP TABLE #space

CREATE TABLE #space (
      [db_name] SYSNAME
    , obj_name SYSNAME
    , total_pages BIGINT
    , used_pages BIGINT
    , total_rows BIGINT
)

DECLARE @SQL NVARCHAR(MAX)

SELECT @SQL = STUFF((
    SELECT '
    USE [' + d.name + ']
    INSERT INTO #space ([db_name], obj_name, total_pages, used_pages, total_rows)
    SELECT DB_NAME(), o.name, t.total_pages, t.used_pages, t.total_rows
    FROM (
        SELECT
              i.[object_id]
            , total_pages = SUM(a.total_pages)
            , used_pages = SUM(a.used_pages)
            , total_rows = SUM(CASE WHEN i.index_id IN (0, 1) AND a.[type] = 1 THEN p.[rows] END)
        FROM sys.indexes i
        JOIN sys.partitions p ON i.[object_id] = p.[object_id] AND i.index_id = p.index_id
        JOIN sys.allocation_units a ON p.[partition_id] = a.container_id
        WHERE i.is_disabled = 0
            AND i.is_hypothetical = 0
        GROUP BY i.[object_id]
    ) t
    JOIN sys.objects o ON t.[object_id] = o.[object_id]
    WHERE o.name NOT LIKE ''dt%''
        AND o.is_ms_shipped = 0
        AND o.type = ''U''
        AND o.[object_id] > 255;'
    FROM sys.databases d
    WHERE d.[state] = 0 and d.name in ('preprod_ab','preprod_cc','preprod_bc','preprod_pc')
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '')

EXEC sys.sp_executesql @SQL

INSERT INTO 
gwre_IT_new..CollectTableSize
SELECT 
      [db_name] as 'DatabaseName'
    , obj_name as 'TableName'
    , total_rows as 'TotalRows'
    , CAST(total_pages * 8. / 1024 AS DECIMAL(18,2)) as  'Totalspace(MB)'
    , CAST(used_pages * 8. / 1024 AS DECIMAL(18,2)) as 'UsedSpace(MB)'
    , CAST((total_pages - used_pages) * 8. / 1024 AS DECIMAL(18,2)) as 'UnusedSpace(MB)'
	,getdate() as Rundate   
FROM #space





GO


