SELECT max_workers_count
FROM sys.dm_os_sys_info

select
    scheduler_id,current_tasks_count, current_workers_count,active_workers_count,work_queue_count
from sys.dm_os_schedulers
where status = 'VISIBLE ONLINE'
go


SELECT  s.session_id, r.command, r.status,  
   r.wait_type, r.scheduler_id, w.worker_address,  
   w.is_preemptive, w.state, t.task_state,  
   t.session_id, t.exec_context_id, t.request_id  
FROM sys.dm_exec_sessions AS s  
INNER JOIN sys.dm_exec_requests AS r  
   ON s.session_id = r.session_id  
INNER JOIN sys.dm_os_tasks AS t  
   ON r.task_address = t.task_address  
INNER JOIN sys.dm_os_workers AS w  
   ON t.worker_address = w.worker_address  
WHERE s.is_user_process = 0;  
