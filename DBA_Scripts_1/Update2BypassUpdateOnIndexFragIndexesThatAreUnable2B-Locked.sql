use GWRE_IT
go

UPDATE [GWRE_IT].[dbo].[IndexFrag]
SET COMMAND='Skipped due to batch processes running and reindexing unable to optain lock on object', 
ERROR_NUM=ERROR_NUMBER(), ERROR_MSG=ERROR_MESSAGE()
WHERE DB_NAME= @DBName -- replace with database name in single quotes
AND TABLE_NAME= @objectname -- replace with table name in single quotes
AND INDEX_NAME like @indexname -- replace with beginnning of index name and % in single quotes
and FRAG > 30 and PAGES > 300
AND COMMAND is null

/*  Example with values
UPDATE [GWRE_IT].[dbo].[IndexFrag]
SET COMMAND='Skipped due to transaction log space issue.', 
ERROR_NUM=ERROR_NUMBER(), ERROR_MSG=ERROR_MESSAGE()
WHERE DB_NAME= 'preprod_pc' -- replace with database name in single quotes
AND TABLE_NAME= 'pc_workflowlog' -- replace with table name in single quotes
AND INDEX_NAME like 'pc_workflowlog_PK%' -- replace with beginnning of index name and % in single quotes
AND FRAG > 30 and PAGES > 300
AND COMMAND is null

-- Select to get only the ones that need to be updated
SELECT * FROM [GWRE_IT].[dbo].[IndexFrag]
WHERE DB_NAME= 'preprod_pc' -- replace with database name in single quotes
AND TABLE_NAME= 'pc_workflowlog' -- replace with table name in single quotes
AND INDEX_NAME like 'pc_workflowlog_PK%' -- replace with beginnning of index name and % in single quotes
AND FRAG > 30 and PAGES > 300
AND COMMAND is null
/*
