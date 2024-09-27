USE tempdb
GO

-- to empty "tempdb4" data file
DBCC SHRINKFILE (tempdb4, EMPTYFILE); 
GO

--to delete "tempdb4" data file
ALTER DATABASE tempdb
REMOVE FILE tempdb4; 
GO
