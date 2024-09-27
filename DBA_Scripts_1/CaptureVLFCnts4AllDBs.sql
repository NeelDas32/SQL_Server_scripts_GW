Create Table #VLF_cnts(
	RecoveryUnitID int
  ,  FileID      int
  , FileSize    bigint
  , StartOffset bigint
  , FSeqNo      bigint
  , [Status]    bigint
  , Parity      bigint
  , CreateLSN   numeric(38)
);
 
Create Table #VLF_results(
    Database_Name   sysname
  , VLF_count       int 
);
 
Exec sp_msforeachdb N'Use ?; 
            Insert Into #VLF_cnts
            Exec sp_executeSQL N''DBCC LogInfo(?)''; 
 
            Insert Into #VLF_results 
            Select DB_Name(), Count(*) 
            From #VLF_cnts; 
 
            Truncate Table #VLF_cnts;'
 
Select * 
From #VLF_results
Order By VLF_count Desc;
 
Drop Table #VLF_cnts;
Drop Table #VLF_results;
