select s.host_name, s.session_id, p.kpid, p.blocked, s.status, p.status, p.cmd, lastwaittype,  WaitTime, 
s.program_name, db_name(dbid) as DB_Name, cast(s.context_info as varchar) Context_Info, s.last_request_start_time, s.row_count 
from sys.dm_exec_sessions s
join sys.sysprocesses p on p.spid = s.session_id 
where s.host_name is not null and db_name(dbid) <> 'master' 
and s.session_id in ( select session_id FROM sys.dm_exec_requests where sql_handle is not null and session_id <> @@SPID) 
order by p.blocked desc, p.waittime desc