EXEC sp_configure 'show advanced options', 1;  
GO  
RECONFIGURE ;  
GO  
EXEC sp_configure 'max worker threads', 1200 ;  
GO  
RECONFIGURE;  
GO 