/******************************************************
   This will give you a list of all your databases, 
   with a column telling you when a successfull CHECKDB 
   was last run:
******************************************************/

CREATE TABLE #tempTotal
(
    DatabaseName varchar(255),
    Field VARCHAR(255),
    Value VARCHAR(255)
)
CREATE TABLE #temp
(
    ParentObject VARCHAR(255),
    Object VARCHAR(255),
    Field VARCHAR(255),
    Value VARCHAR(255)
)

EXECUTE sp_MSforeachdb '
INSERT INTO #temp EXEC(''DBCC DBINFO ( ''''?'''') WITH TABLERESULTS'')
INSERT INTO #tempTotal (Field, Value, DatabaseName)
SELECT Field, Value, ''?'' FROM #temp
TRUNCATE TABLE #temp';

;WITH cte as
(
    SELECT
        ROW_NUMBER() OVER(PARTITION BY DatabaseName, Field 
        ORDER BY Value DESC) AS rn,
        DatabaseName,
        Value
    FROM #tempTotal t1
    WHERE (Field = 'dbi_dbccLastKnownGood')
)
SELECT
    DatabaseName,
    Value as dbccLastKnownGood
FROM cte
WHERE (rn = 1)
order by 2

DROP TABLE #temp
DROP TABLE #tempTotal
