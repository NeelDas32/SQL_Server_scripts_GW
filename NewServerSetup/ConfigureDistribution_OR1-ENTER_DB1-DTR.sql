/****** Scripting replication configuration. Script Date: 7/7/2014 4:55:21 PM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Installing the server as a Distributor. Script Date: 7/7/2014 4:55:21 PM ******/



--Replace ENTER_DB1 with a client DB name ended by 1 - for example CBIC1 and run on OR1-DTR server

use master
exec sp_adddistributor @distributor = N'ENTER_NAME1-DTR', @password = N'SQL@dm1n'
GO
exec sp_adddistributiondb @database = N'distribution', @data_folder = N'F:\Data', @log_folder = N'L:\Logs', @log_file_size = 2, @min_distretention = 0, @max_distretention = 72, @history_retention = 48, @security_mode = 1
GO

use [distribution] 
if (not exists (select * from sysobjects where name = 'UIProperties' and type = 'U ')) 
	create table UIProperties(id int) 
if (exists (select * from ::fn_listextendedproperty('SnapshotFolder', 'user', 'dbo', 'table', 'UIProperties', null, null))) 
	EXEC sp_updateextendedproperty N'SnapshotFolder', N'\\ENTER_NAME1-DTR\ReplData', 'user', dbo, 'table', 'UIProperties' 
else 
	EXEC sp_addextendedproperty N'SnapshotFolder', N'\\ENTER_NAME1-DTR\ReplData', 'user', dbo, 'table', 'UIProperties'
GO

exec sp_adddistpublisher @publisher = N'ENTER_NAME1-DB', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\ENTER_NAME1-DTR\ReplData', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO
exec sp_adddistpublisher @publisher = N'ENTER_NAME1-MIR', @distribution_db = N'distribution', @security_mode = 1, @working_directory = N'\\ENTER_NAME1-DTR\ReplData', @trusted = N'false', @thirdparty_flag = 0, @publisher_type = N'MSSQLSERVER'
GO


 exec sp_add_agent_parameter @profile_id = 1, @parameter_name = N'-PublisherFailoverPartner', @parameter_value = N'ENTER_NAME1-MIR' 
 exec sp_add_agent_parameter @profile_id = 2, @parameter_name = N'-PublisherFailoverPartner', @parameter_value = N'ENTER_NAME1-MIR'
 exec sp_add_agent_parameter @profile_id = 3, @parameter_name = N'-PublisherFailoverPartner', @parameter_value = N'ENTER_NAME1-MIR'