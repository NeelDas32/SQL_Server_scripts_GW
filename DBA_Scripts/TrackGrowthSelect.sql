-- Insert into Temporary Table
select f.dbname as Database_Name, 
cast((d.datasize_mb/1024) as decimal(12,2)) as Current_DBSize_GB,
CASE WHEN 
100 - (cast(round(sum(available_space_mb)/sum(f.total_size_mb),2)as decimal(4,2))* 100) <= 0
THEN 1 ELSE
100 - (cast(round(sum(available_space_mb)/sum(f.total_size_mb),2)as decimal(4,2))* 100) 
END as DataFiles_Percent_Full, 
cast((sum(max_filesize_mb)/1024) as decimal(10,0)) as DB_MaxFileSize_GB, 
CASE WHEN 
cast(round(sum(percent_full)/COUNT(f.dbname),2) as decimal(4,0)) <= 0
THEN 1 ELSE
cast(round(sum(percent_full)/COUNT(f.dbname),2) as decimal(4,0))
END as DB_Percent_Full, 
dateadded as ReportDate, checkdate as AddedDate
into #DBFileSizes
from ISCS_IT.dbo.filesize_tbl f
join ISCS_IT.dbo.dbsize_tbl d on f.dbname = d.dbname
and dateadd(dy,0,datediff(dd,0,dateadded)) = dateadd(dy,0,datediff(dd,0,checkdate))
where filename not like '%_log%'
group by f.dbname, dateadded, d.datasize_mb, checkdate;
  
-- Select data from Temporary Table
SELECT * from #DBFileSizes

set @rowcount = @@ROWCOUNT

-- Fill message detail
IF @rowcount > 0 
SET @message_dtl = 
 N'<H4>Database DataFile Percent Used Report For ' + @@ServerName + ' Generated: ' + convert(varchar(25), current_timestamp, 100) +'</H4>' +
    N'<table border="1"><FONT FACE="Arial, Helvetica, Geneva" SIZE="-2">' + N'<th>Database_Name</th>' +
    N'<th>Current_DBSize_GB</th><th>DataFiles_Percent_Full</th><th>DB_MaxFileSize_GB</th><th>DB_Percent_Full</th><th>DateTimeChecked</th></tr>' +
    CAST ( ( SELECT td = Database_Name, '',
	td = Current_DBSize_GB, '',
        td = DataFiles_Percent_Full, '',
    	td = DB_MaxFileSize_GB, '',
        td = DB_Percent_Full, '',
	td = ReportDate, ''                
FROM #DBFileSizes
WHERE ReportDate > Getdate()-1 
ORDER BY DB_Percent_Full DESC
FOR XML PATH('tr'), TYPE ) AS NVARCHAR(MAX)) + N'</FONT></table>';

-- Drop table #DBFileSizes

