USE [GWRE_IT]
GO

/****** Object:  StoredProcedure [dbo].[CPUIDLE]    Script Date: 7/30/2024 11:15:33 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE procedure [dbo].[CPUIDLE] as
DECLARE

@TextTitle varchar(8000),
@TextTitle1 varchar(8000),
@TableHTML nvarchar(max),
@Body1 nvarchar(max),
@Body nvarchar(max)
declare @qtCICLOS int

declare @qttime int

declare @time int

declare @tempototal int

declare @Percentual_Ocioso int

set @qttime = 0

set @time = 0

SET @qtCICLOS = 20-- Here you can change. 

-- 20 is the number of times the loop will be executed before averaging.

while @qttime < @qtCICLOS

begin

select @tempototal = (SELECT cpu_idle = record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int')

--Measures CPU idle,

FROM (

SELECT TOP 1 CONVERT(XML, record) AS record

FROM sys.dm_os_ring_buffers

WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'

AND record LIKE '% %'

ORDER BY TIMESTAMP DESC

) as cpu_usage)

set @qttime = @qttime + 1

set @time = @time + @tempototal

WAITFOR DELAY '00:00:03' 

  -- here you can change. In each of the 20 loops, this process will wait for 5 seconds. 

  -- With this, every 30 seconds, this procedure will calculate the average CPU idle.

end

SET @TextTitle = 'CPU Usage  Report for Preprod Database server  '
SET @TextTitle1 = 'Below is the CPU usage in the server from the past 60 mins '
 
SET 
@TableHTML =
'<html>'+
'<head><style>'+
-- Data cells styles / font size etc
'td {border:1px solid #ddd;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:10pt}'+
'td.red {border:1px solid #ddd;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:10pt;background-color: #FF0000}'+
   
'</style></head>'+
'<body>'+
-- TextTitle style
'<div style="margin-top:20px; margin-left:20px; margin-bottom:20px; font-weight:bold; font-size:13pt; font-family:calibri;">' + @TextTitle +'</div>' +

-- TextTitle1 style
'<div style="margin-top:20px; margin-left:20px; margin-bottom:20px; font-weight:bold; font-size:13pt; font-family:calibri;">' + @TextTitle1 +'</div>' +

-- Color and columns names
'<div style="font-family:Calibri; "><table>'+'<tr bgcolor=#1d0088>'+
'<td align=left><font face="calibri" color=White><b>SQLServer_CPU_Utilization</b></font></td>'+ -- SQLServer_CPU_Utilization
'<td align=left><font face="calibri" color=White><b>System_Idle_Process</b></font></td>'+ -- System_Idle_Process
'<td align=left><font face="calibri" color=White><b>Other_Process_CPU_Utilization</b></font></td>'+ -- Other_Process_CPU_Utilization
'<td align=left><font face="calibri" color=White><b>Event_Time</b></font></td>'+ -- Event_Time
'</tr></div>'

DECLARE @ts BIGINT;
DECLARE @lastNmin TINYINT;
SET @lastNmin = 60;
SELECT @ts =(SELECT cpu_ticks/(cpu_ticks/ms_ticks) FROM sys.dm_os_sys_info); 
SELECT TOP(@lastNmin)
		SQLProcessUtilization AS [SQLServer_CPU_Utilization], 
		SystemIdle AS [System_Idle_Process], 
		100 - SystemIdle - SQLProcessUtilization AS [Other_Process_CPU_Utilization], 
		DATEADD(ms,-1 *(@ts - [timestamp]),GETDATE())AS [Event_Time] 
	into #Cpuusage 
FROM (SELECT record.value('(./Record/@id)[1]','int')AS record_id, 
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]','int')AS [SystemIdle], 
record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]','int')AS [SQLProcessUtilization], 
[timestamp]      
FROM (SELECT[timestamp], convert(xml, record) AS [record]              
FROM sys.dm_os_ring_buffers           
WHERE ring_buffer_type =N'RING_BUFFER_SCHEDULER_MONITOR'AND record LIKE'%%')AS x )AS y 
ORDER BY record_id DESC; 



-- If the average cpu idle level is below 5% in the last 30 seconds, that is, if the cpu usage is above 95%, an alert email will be sent.



-- drop table #Cpuusage
--select * from #Cpuusage
Select @Body = Cast((SELECT td=[SQLServer_CPU_Utilization],'',
                            td=[System_Idle_Process],'',
                            td= [Other_Process_CPU_Utilization],'',
							td=[Event_Time],''
							
													 
                        
                                              
               FROM   #Cpuusage
				  FOR xml path('tr'), elements) AS NVARCHAR(max)) 
				 
				 SET @Body = REPLACE(@Body, '<td>', '<td align=left><font face="calibri">')
SET @TableHTML = @TableHTML + @Body + '</table></div></body></html>'
SET @TableHTML = '<div style="color:Black; font-size:8pt; font-family:Calibri; width:auto;">' + @TableHTML + '</div>'

select @Percentual_Ocioso = (Select (@time/@qtCICLOS) CPU_IDLE)

select @Percentual_Ocioso as Percentual_CPU_Ociosa

if @Percentual_Ocioso < = 5 -- Here you can change !!


exec msdb.dbo.sp_send_dbmail
@profile_name = 'Amazon SES SMTP',  
@Recipients = 'chris.woolmer@icare.nsw.gov.au;amarnathreddy.chinthapalli@icare.nsw.gov.au;vigneshkumar.s@icare.nsw.gov.au;gerard.thackray@icare.nsw.gov.au',
@Body = @TableHTML ,
@Subject = 'ATTENTION, PREPROD DATABASE SERVER CPU: MORE THAN 95% OF USE IN THE PAST  60 SECONDS',
@Body_format = 'HTML'
-- end



GO


