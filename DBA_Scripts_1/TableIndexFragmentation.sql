/***********************************************************
   This script will return the percent of fragmentation for 
   all the indexes on a particular table in the database.  
   Update the DB_ID and TABLE_NAME with desired info.
   
   Created by: S.Kratzer
   Date: 09/22/2015
***********************************************************/

SELECT TABLE_SCHEMA,object_name(F.object_id) OBJ,I.name IND, 
      F.avg_fragmentation_in_percent,
      F.page_count, 
      CASE WHEN I.allow_row_locks=1 THEN 'ON'
      ELSE 'OFF'
      END as ALLOWROWSLOCKS, 
      CASE WHEN I.allow_page_locks=1 THEN 'ON'
      ELSE 'OFF'
      END AS ALLOWPAGELOCKS, 
      CASE WHEN I.fill_factor=0 THEN 100 ELSE I.fill_factor END as FILL_FACTOR, NULL, NULL, NULL
      FROM sys.dm_db_index_physical_stats (DB_ID('preprod_cc'), object_id('cc_contact'),NULL,NULL,NULL) F
      JOIN sys.indexes I
      ON(F.object_id=I.object_id) AND I.index_id=F.index_id
      JOIN INFORMATION_SCHEMA.TABLES S
      ON (S.TABLE_NAME=OBJECT_NAME(F.object_id))
      WHERE I.index_id <> 0
      AND F.database_id='8'
      AND S.TABLE_SCHEMA = 'dbo'
      AND OBJECTPROPERTY(I.object_id,'ISSYSTEMTABLE')=0 order by I.name
      