USE [GWRE_IT]
GO

/****** Object:  StoredProcedure [dbo].[setdbowner]    Script Date: 7/30/2024 11:17:08 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[setdbowner] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


DECLARE @name VARCHAR(50)
declare @sqlcmd varchar(max)

DECLARE db_cursor CURSOR FOR 
SELECT name 
FROM MASTER.dbo.sysdatabases 
WHERE name NOT IN ('master','model','msdb','tempdb','GWRE_IT') 
and name not like '%GWPREPROD%' -- do not include GWPREPROD databases per https://guidewirejira.atlassian.net/browse/CLOUD-103788


OPEN db_cursor  
FETCH NEXT FROM db_cursor INTO @name  

WHILE @@FETCH_STATUS = 0  
BEGIN  
 set @sqlcmd = 'use '+ @name +'
if NOT exists (select 1 from sys.database_principals where name = ''GWRE-CLOUD\ICARE-DEV-GUEST-DBA'')
begin
CREATE USER [GWRE-CLOUD\ICARE-DEV-GUEST-DBA] FOR LOGIN [GWRE-CLOUD\ICARE-DEV-GUEST-DBA] WITH DEFAULT_SCHEMA=[dbo]
Alter role db_owner ADD MEMBER [GWRE-CLOUD\ICARE-DEV-GUEST-DBA]
end'

exec(@sqlcmd)


FETCH NEXT FROM db_cursor INTO @name 
END 

CLOSE db_cursor  
DEALLOCATE db_cursor 
END





GO


