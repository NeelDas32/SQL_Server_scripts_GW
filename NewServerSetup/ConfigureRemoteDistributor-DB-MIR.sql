/****** Scripting replication configuration. Script Date: 7/14/2014 11:00:39 AM ******/
/****** Please Note: For security reasons, all password parameters were scripted with either NULL or an empty string. ******/

/****** Installing the server as a Distributor. Script Date: 7/14/2014 11:00:39 AM ******/
use master
exec sp_adddistributor @distributor = N'SC1-ENTER_DB1-DTR', @password = N'SQL@dm1n'
GO

