select name
from sys.databases
where is_read_committed_snapshot_on = 1

/*
ALTER DATABASE uatCBIC
SET READ_COMMITTED_SNAPSHOT ON;
*/
