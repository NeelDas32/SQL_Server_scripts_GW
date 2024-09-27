-- Script to show advanced options --
use master
go
sp_configure 'show advanced option', '1';
GO
RECONFIGURE;
GO
EXEC sp_configure;
GO 
