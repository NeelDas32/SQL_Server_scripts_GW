-- check Global trace flags
dbcc tracestatus (-1)

-- traceflags for Datahub
dbcc traceon (9481,-1)

-- turn on trace flags
dbcc traceon (2861,3226,4199,-1)
-- 2861 Is enabled by Solarwinds DPA monitor
-- 3226 suppresses the log entries for backup operations
-- 4199 Enables query optimizer fixes released in SQL Server CU and SP.

-- trace flag Enables singleton updates for Transactional Replication and CDC.
dbcc traceon (8207,-1)

-- traceflags for deadlocks
dbcc traceon (1204,1222,3605,-1)

