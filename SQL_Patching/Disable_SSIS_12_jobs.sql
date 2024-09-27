USE msdb
GO
select @@SERVERNAME as ServerName, name as JobName,enabled,date_modified 
from msdb..sysjobs where name in('CRIF_GWSAPIntegrationi11','CRIF_GWSAPIntegrationi14','CRIF_GWSAPIntegrationPreprod','CRIF_GWSAPIntegrationSIT14','NI_GWSAPRecoveryPREPROD','NI_GWSAPIntegrationPREPROD'
,'NI_GWSAPRecoveryi11','NI_GWSAPRecoveryi14','NI_GWSAPRecoverySIT14','NI_GWSAPIntegrationi11','NI_GWSAPIntegrationSIT14','NI_GWSAPIntegrationi14')
----
EXEC dbo.sp_update_job
    @job_name = N'CRIF_GWSAPIntegrationi11', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'CRIF_GWSAPIntegrationi14', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'CRIF_GWSAPIntegrationPreprod', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'CRIF_GWSAPIntegrationSIT14', @enabled = 0
----
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPRecoveryi11', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPRecoveryi14', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPRecoveryPREPROD', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPRecoverySIT14', @enabled = 0
----
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPIntegrationi11', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPIntegrationi14', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPIntegrationPREPROD', @enabled = 0
EXEC dbo.sp_update_job
    @job_name = N'NI_GWSAPIntegrationSIT14', @enabled = 0
GO
select @@SERVERNAME as ServerName, name as JobName,enabled,date_modified 
from msdb..sysjobs where name in('CRIF_GWSAPIntegrationi11','CRIF_GWSAPIntegrationi14','CRIF_GWSAPIntegrationPreprod','CRIF_GWSAPIntegrationSIT14','NI_GWSAPRecoveryPREPROD','NI_GWSAPIntegrationPREPROD'
,'NI_GWSAPRecoveryi11','NI_GWSAPRecoveryi14','NI_GWSAPRecoverySIT14','NI_GWSAPIntegrationi11','NI_GWSAPIntegrationSIT14','NI_GWSAPIntegrationi14')