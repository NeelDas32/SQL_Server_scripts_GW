-- List the active transactions in order, by longest running transaction
select a.transaction_id, d.name, e.host_name,
b.session_id, b.elapsed_time_seconds/60/60.00 as elapsed_time_hours,
b.elapsed_time_seconds/60 as elapsed_time_minutes, 
b.transaction_sequence_num 
from sys.dm_tran_database_transactions a
join sys.dm_tran_active_snapshot_database_transactions b
on b.transaction_id = a.transaction_id
join sys.databases d on a.database_id = d.database_id
join sys.dm_exec_sessions e on b.session_id = e.session_id
ORDER BY elapsed_time_seconds DESC;
