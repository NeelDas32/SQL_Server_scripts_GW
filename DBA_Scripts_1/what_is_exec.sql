select text, session_id, blocking_session_id as blocker, command, percent_complete, 
status, database_id, start_time, wait_type, wait_time, last_wait_type, 
wait_resource, transaction_id, open_transaction_count, cpu_time,
reads, writes, logical_reads --, r.* 
from sys.dm_exec_requests r																																																		
cross apply sys.dm_exec_sql_text(r.sql_handle) Q

order by command desc																																																		
--where session_id >= 50	

-- select * from sys.databases

-- sp_who2 1218
-- dbcc inputbuffer (1218)




