 /*********************************************************************
 Check for connections to SJ1-CSE1-DW that are coming from the 
  Read-Only Report User.  
  Author: S. Kratzer
  Date: 05/01/2014
*************************************************************************/
-- Declare Variables
declare @rowcount int
declare @recipient_list varchar(200)
declare @message varchar(max)
declare @message_dtl varchar(max)
declare @e_subject varchar(200)

-- Select into temporary table

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
INTO #CONNECTIONS
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
and login_name = 'prodCSE_ro_reportuser' -- Find Read Only Report User Connection

set @rowcount = 0
SELECT * from #CONNECTIONS
set @rowcount = @@ROWCOUNT

-- Load Message Detail Table
SET @message_dtl =  N'<H4>Read-Only Report User Connections Report For ' + @@ServerName + ' Generated: ' + convert(varchar(25), current_timestamp, 100) +'</H4>' +
    N'<table border="1"><FONT FACE="Arial, Helvetica, Geneva" SIZE="-2">' + N'<th>Session_Id</th>' +
    N'<th>Program_Name</th><th>Login</th><th>Host_Name</th>' +
    N'<th>CPU_Time</th><th>DiskIO</th><th>Last_Batch_Dttm</th><th>Status</th></tr>' +
    CAST ( ( SELECT td = SPID, '',
                td = ProgramName, '',
				td = Login, '',
                td = HostName, '',
                td = CPUTime, '',
                td = DiskIO, '',
				td = LastBatchDttm,'',
				td = Status,''
FROM #CONNECTIONS
ORDER BY LastBatchDttm
FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX)) + N'</FONT></table>';

-- Send Report
IF @rowcount > 0 
  BEGIN 
      SET @recipient_list = 'susan.kratzer@iscs.com' 
      SET @message = 'Read-Only Report User connections to SQL Server ' + @@servername + @message_dtl
      SET @e_subject = 'Read-Only Report User connections to SQL Server ' + @@servername 
      EXEC msdb..sp_send_dbmail @profile_name = 'SJ1-CSE1-DW',@recipients = @recipient_list , @body=@message, @subject=@e_subject, @body_format = 'HTML';
  END
-- Drop Temporary Tables
DROP TABLE #CONNECTIONS