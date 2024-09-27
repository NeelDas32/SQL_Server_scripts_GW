select 'SELECT MAX(DATALENGTH(' + column_name + ')) FROM PolicySummaryStats;'
FROM information_schema.columns

WHERE table_schema = 'dbo'
 
and table_name='PolicySummaryStats' 

and data_type = 'varchar'
ORDER BY ordinal_position; 