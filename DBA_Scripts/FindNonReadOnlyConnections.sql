/*************************************************************************************************************
  Check for connections to the database server that are not coming from the Innovation software.   
  or from SQL Server and are not using the spisupp_ro_user login. 
  Author: S. Kratzer
  Date: 09/30/2015
***************************************************************************************************************/
-- Declare Variables
declare @rowcount int
declare @recipient_list varchar(200)
declare @message varchar(max)
declare @message_dtl varchar(max)
declare @e_subject varchar(200)

SELECT  
   A.Session_ID SPID, 
   A.program_name ProgramName,
   A.login_name Login, 
   A.host_name HostName, 
   CASE WHEN (DB_NAME(C.Database_ID)is NULL) 
   THEN ' ' ELSE DB_NAME(C.Database_ID) END AS DBName,
   ISNULL(B.status,A.status) Status, 
   CASE WHEN (C.BlkBy is NULL) 
   THEN ' ' ELSE C.BlkBy END AS BlockedBy,
   ISNULL(B.cpu_time, A.cpu_time) CPUTime, 
   ISNULL((B.reads + B.writes),(A.reads + A.writes)) DiskIO,  
   A.last_request_start_time LastBatchDttm
FROM    
   sys.dm_exec_sessions A    
   LEFT JOIN sys.dm_exec_requests B 
   ON A.session_id = B.session_id   
   LEFT JOIN  
      (SELECT A.request_session_id SPID,  
			B.blocking_session_id BlkBy,
			A.resource_database_id Database_ID
       FROM sys.dm_tran_locks as A             
          INNER JOIN sys.dm_os_waiting_tasks as B 
          ON A.lock_owner_address = B.resource_address) C 
   ON A.Session_ID = C.SPID   
OUTER APPLY sys.dm_exec_sql_text(sql_handle) D
where A.Session_ID > 50 -- Eliminate SQL Server connections
and program_name <> 'Innovation_Rq'  -- Eliminate Innovation Connections
and program_name <> 'Innovation_DW'  
and login_name <> 'spisupp_ro_user' -- Eliminate Support Read Only Connections
and login_name not like 'ISCSUS%' -- Eliminate Domain Connections
and login_name <> 'sa' -- Eliminate System Administrator Connections
and login_name <> 'distributor_admin'  -- Eliminate the Distribution Admin
and host_name <> @@servername -- Eliminate Local Server Connections
and host_name not like 'spi%'  -- Eliminate Application Servers using Microsoft SQL Server JDBC Driver

