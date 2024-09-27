sqlcmd -i F:\NewServerSetup\Production\StoredProcedures\Create_GWRE_IT_Database.sql

sqlcmd -i F:\NewServerSetup\Production\StoredProcedures\Create_IndexFrag_Tbl.sql 
sqlcmd -i F:\NewServerSetup\Production\StoredProcedures\Create_UpdateStats_Tbl.sql 
sqlcmd -i F:\NewServerSetup\Production\StoredProcedures\gwre_IndexMaintenance.sql 
sqlcmd -i F:\NewServerSetup\Production\StoredProcedures\gwre_UpdateStatistics.sql 

sqlcmd -i F:\NewServerSetup\Production\Create_SQLDBA_Operator.sql
sqlcmd -i F:\NewServerSetup\Production\Create_Alert-DBA.sql
sqlcmd -i F:\NewServerSetup\Production\Create_sp_help_revlogin.sql

sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\AgentStartupNotification.sql
sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\CheckActiveTransactions.sql
sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\DBCC_CheckDB_AllDBs.sql
sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\IndexMaintenance.sql
sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\RotateSQLErrorLogs.sql
sqlcmd -i F:\NewServerSetup\Production\SQLJobScripts\UpdateStatistics_AllDBs.sql

