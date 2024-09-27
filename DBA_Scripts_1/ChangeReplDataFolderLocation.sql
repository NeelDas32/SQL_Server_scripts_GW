-- Locate and update ReplDsata Folder
select name, working_directory from msdb.dbo.MSdistpublishers

exec sp_changedistpublisher @publisher = 'SJ1-FMS1-DW', @property = 'working_directory', @value = '\\SJ1-FMS1-DW\ReplData'

-- Locate and update Snapshot Folder
select * from sysobjects where name = 'UIProperties' and type = 'U '

select * from ::fn_listextendedproperty('SnapshotFolder', 'user', 'dbo', 'table', 'UIProperties', null, null)

EXEC sp_updateextendedproperty N'SnapshotFolder', N'\\SJ1-FMS1-DW\ReplData', 'user', dbo, 'table', 'UIProperties' 
