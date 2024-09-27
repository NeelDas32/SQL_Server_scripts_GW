SELECT database_name, principal_server_name, 
mirror_server_name, database_name, safety_level_desc, *
FROM sys.database_mirroring_witnesses (nolock)
order by 2, 1
