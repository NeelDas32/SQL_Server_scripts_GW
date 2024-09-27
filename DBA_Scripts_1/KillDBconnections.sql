DECLARE @dbname sysname
 
SET @dbname = 'preprod_pc_temp'--- Please enter the DB Name here
 
DECLARE @spid int
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname)

WHILE @spid IS NOT NULL
BEGIN
EXECUTE ('KILL ' + @spid)
SELECT @spid = min(spid) from master.dbo.sysprocesses 
where dbid = db_id(@dbname) AND spid > @spid
END
