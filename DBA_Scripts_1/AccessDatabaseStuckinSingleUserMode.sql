-- Use the MASTER DB (because you can’t access the db in question)
use master
go
-- Determine which SPID needs to be killed (replace DBName with database stuck in single user mode)
select * from master.sys.sysprocesses
where spid > 50 and dbid = DB_ID('DBName')

-- Replace 100 below with SPID found in above query 
-- Highlight and run kill and alter statement together
kill 100

-- Change database to multi user mode
alter database suppDMIC
set multi_user with rollback immediate
