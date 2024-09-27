USE [GWRE_IT_NEW]
GO

/****** Object:  StoredProcedure [dbo].[sp_monitor_disk_free_space]    Script Date: 7/30/2024 11:13:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[sp_monitor_disk_free_space]
   @PercentFree int 
AS

SET NOCOUNT ON

-- Create the temp table #Drives
IF EXISTS ( SELECT  name
            FROM    tempdb.sys.tables
            WHERE   name LIKE '#Drives%' )
    DROP TABLE #Drives

CREATE TABLE #Drives
    (
      Drive CHAR(3) PRIMARY KEY ,
      FreeSpace INT NULL ,
      TotalSize INT NULL ,
      [PercentFree] AS ( CONVERT(FLOAT, FreeSpace) / TotalSize ) * 100
    ) 

-- Insert the info on the table by DMF sys.dm_os_volume_stats
INSERT  #Drives
        ( Drive ,
          FreeSpace ,
          TotalSize
        )
        SELECT DISTINCT
                dovs.volume_mount_point ,
                CONVERT(INT, dovs.available_bytes / 1048576.0) ,
                CONVERT(INT, dovs.total_bytes / 1048576.0)
        FROM    sys.master_files mf
                CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) dovs
        ORDER BY dovs.volume_mount_point ASC

-- Variables for mail send
DECLARE @tableHTML NVARCHAR(MAX)

-- Creates the HTML to the report sending with the total free space info
SET @tableHTML = N'<H1>Disk usage</H1>' + N'<table border="1">'
    + N'<tr><th>Drive</th><th>Total (MB)</th><th>Free (MB)</th><th>% Free</th></tr>'
    + CAST(( SELECT CASE WHEN [PercentFree] <= @PercentFree THEN '#FF0000'
                    END AS 'td/@BGCOLOR' ,
                    td = Drive ,
                    '' ,
                    'right' AS 'td/@align' ,
                    CASE WHEN [PercentFree] <= @PercentFree THEN '#FF0000'
                    END AS 'td/@BGCOLOR' ,
                    td = TotalSize ,
                    '' ,
                    'right' AS 'td/@align' ,
                    CASE WHEN [PercentFree] <= @PercentFree THEN '#FF0000'
                    END AS 'td/@BGCOLOR' ,
                    td = FreeSpace ,
                    '' ,
                    'right' AS 'td/@align' ,
                    CASE WHEN [PercentFree] <= @PercentFree THEN '#FF0000'
                    END AS 'td/@BGCOLOR' ,
                    td = CONVERT (NUMERIC(10, 2), [PercentFree])
             FROM   #Drives
           FOR
             XML PATH('tr') ,
                 TYPE
           ) AS NVARCHAR(MAX)) + N'</table>';


-- Calls the procedure sp_send_dbmail to send the email using the SQLAgentDBA profile created on 
 
exec msdb.dbo.sp_send_dbmail
@profile_name = 'Amazon SES SMTP',  
@Recipients = 'chris.woolmer@icare.nsw.gov.au;amarnathreddy.chinthapalli@icare.nsw.gov.au;vigneshkumar.s@icare.nsw.gov.au;gerard.thackray@icare.nsw.gov.au',
@Body = 'Please find the disk space usage details below. Take necessary actions tl clean up space',
@Subject = 'Disk Space Usage in Preprod server drive is more than 95%',
@Body_format = 'HTML'

RETURN 0


GO


