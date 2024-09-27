-- Check the net use mapping
exec xp_cmdshell 'net use'
go

-- If B exist, drop it so it can be recreated
exec xp_cmdshell 'net use B: /delete'
go

-- recreate the mapping to the au1-bkp01 server
exec xp_cmdshell 'net use B: \\10.150.0.28\H$\NonProdDbBackups\Dev Sq1s@fe! /User:GWRE-CLOUD\SQLsafe /PERSISTENT:yes'
go