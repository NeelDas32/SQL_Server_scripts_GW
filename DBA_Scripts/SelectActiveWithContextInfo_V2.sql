SELECT session_id, start_time, status, blocking_session_id, wait_time, last_wait_type, wait_resource, CAST(context_info AS varchar(100)),
(SELECT TOP 1 SUBSTRING(s2.text, eqs.statement_start_offset / 2 + 1 , (( CASE WHEN eqs.statement_end_offset = -1 THEN (LEN(CONVERT(nvarchar(MAX),s2.text)) * 2) ELSE eqs.statement_end_offset END) - eqs.statement_start_offset) / 2 + 1) ) AS querytext,
(CASE WHEN eqs.statement_start_offset < 10 THEN '' ELSE 'DECLARE ' + SUBSTRING(s2.text, 2, eqs.statement_start_offset/2 - 2) END ) AS args
FROM sys.dm_exec_requests er CROSS APPLY sys.dm_exec_input_buffer(er.session_id, NULL) AS input_buffer
INNER JOIN  sys.dm_exec_query_stats eqs CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS s2 ON er.query_hash = eqs.query_hash
