SELECT
  sys.columns.name AS ColumnName,
  sys.tables.name AS TableName
FROM
  sys.columns
JOIN sys.tables ON
  sys.columns.object_id = sys.tables.object_id
  and schema_id = 1
WHERE
  sys.columns.name = 'UpdateUser'
  order by TableName
  
