USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[usp_long_running_jobs]    Script Date: 7/30/2024 11:14:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[usp_long_running_jobs] as

DECLARE
@EmailSubject varchar(100),
@TextTitle varchar(8000),
@TextTitle1 varchar(8000),
@TextTitle2 varchar(8000),
@TableHTML nvarchar(max),
@Body nvarchar(max),
@cnt int
SET @EmailSubject = 'NI GWSAP Job running more than 15 min '
SET @TextTitle = 'Please find the NI GWSAP Job running more than 15 min below'

SET @TextTitle1 = 'Check for the indexes [bc_transaction_Updatetime] and [bc_transaction_reversed] in the respective bc database. eg. sit6_bc'
SET @TextTitle2 =' Run the below script if index is not present(due to re-deploy) and re-run the job. It will execute within 5 min.
CREATE UNIQUE NONCLUSTERED INDEX [bc_transaction_Updatetime]
ON [dbo].[bc_transaction] ([UpdateTime], [Reversed],[CreateTime],[TransactionDate],[Currency],[ID],[TransactionNumber],[Subtype])
CREATE NONCLUSTERED INDEX [bc_transaction_reversed] ON [dbo].[bc_transaction]
([Reversed],[TransactionNumber],[CreateTime]
) '

 
SET 
@TableHTML =
'<html>'+
'<head><style>'+
-- Data cells styles / font size etc
'td {border:1px solid #ddd;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font-size:10pt}'+
'</style></head>'+
'<body>'+
-- TextTitle style
'<div style="margin-top:15px; margin-left:15px; margin-bottom:15px; font-weight:bold; font-size:13pt; font-family:calibri;">' + @TextTitle +'</div>' +
-- TextTitle1 style
'<div style="margin-top:20px; margin-left:20px; margin-bottom:15px; font-weight:bold; font-size:13pt; font-family:calibri;">' + @TextTitle1 +'</div>' +
-- TextTitle2 style
'<div style="margin-top:20px; margin-left:20px; margin-bottom:15px; font-size:13pt; font-family:calibri;">' + @TextTitle2 +'</div>' +

-- Color and columns names
'<div style="font-family:Calibri; "><table>'+'<tr bgcolor=#1d0088>'+
'<td align=left><font face="calibri" color=White><b>JobName</b></font></td>'+ -- JobName
'<td align=left><font face="calibri" color=White><b>RunDurationMinutes</b></font></td>'+ -- RunDuration
'<td align=left><font face="calibri" color=White><b>LastRunDateTime(AEST)</b></font></td>'+ -- Last Execution Time

'</tr></div>'
-------------------------------------------------------------------------------------------------------------------------------------
----- Querying stats for long running Jobs 
-------------------------------------------------------------------------------------------------------------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
WITH XMLNAMESPACES (DEFAULT 'http://schemas.microsoft.com/sqlserver/2004/07/showplan'),
LongRunningJobs AS (
SELECT
    j.name as 'JobName',
    ((h.run_duration/10000*3600 + (h.run_duration/100)%100*60 + h.run_duration%100 + 31 ) / 60) 
      as 'RunDurationMinutes',
    LastRunDateTime = CONVERT(DATETIME, RTRIM(run_date) + ' '
        + STUFF(STUFF(REPLACE(STR(RTRIM(h.run_time),6,0),
        ' ','0'),3,0,':'),6,0,':'))
FROM
    msdb.dbo.sysjobs AS j
INNER JOIN
    (
        SELECT job_id, instance_id = MAX(instance_id)
            FROM msdb.dbo.sysjobhistory
            GROUP BY job_id
    ) AS l
    ON j.job_id = l.job_id
INNER JOIN
    msdb.dbo.sysjobhistory AS h
    ON h.job_id = l.job_id
    AND h.instance_id = l.instance_id
	where j.name like '%NI_SAP%'
	and ((h.run_duration/10000*3600 + (h.run_duration/100)%100*60 + h.run_duration%100 + 31 ) / 60) > 15
)
----------------------------------------------------------
----------------------------------------------------------
SELECT @Body =(
SELECT
td = JobName,
td = RunDurationMinutes,
td = CONVERT(VARCHAR(20),LastRunDateTime,100)

FROM
LongRunningJobs

for XML raw('tr'), elements)
SET @Body = REPLACE(@Body, '<td>', '<td align=left><font face="calibri">')
SET @TableHTML = @TableHTML + @Body + '</table></div></body></html>'
SET @TableHTML = '<div style="color:Black; font-size:8pt; font-family:Calibri; width:auto;">' + @TableHTML + '</div>'


select @cnt = count(*) from  msdb.dbo.sysjobs AS j
INNER JOIN
    (
        SELECT job_id, instance_id = MAX(instance_id)
            FROM msdb.dbo.sysjobhistory
            GROUP BY job_id
    ) AS l
    ON j.job_id = l.job_id
INNER JOIN
    msdb.dbo.sysjobhistory AS h
    ON h.job_id = l.job_id
    AND h.instance_id = l.instance_id
	where j.name like '%NI_SAP%' 
	and ((h.run_duration/10000*3600 + (h.run_duration/100)%100*60 + h.run_duration%100 + 31 ) / 60) > 15
    
	
if @cnt > 0 
-------------------------------
----- Sending email --------
-------------------------------
exec msdb.dbo.sp_send_dbmail
@profile_name = 'Amazon SES SMTP',  
@Recipients = 'cloudopsdba@guidewire.com',
@Body = @TableHTML,
@Subject = @EmailSubject,
@Body_format = 'HTML'

GO


