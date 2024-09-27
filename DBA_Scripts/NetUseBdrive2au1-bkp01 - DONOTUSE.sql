-- Check the net use mapping
exec xp_cmdshell 'net use'
go

-- If B exist, drop it so it can be recreated
exec xp_cmdshell 'net use W: /delete'
go

-- recreate the mapping to the au1-bkp01 server
exec xp_cmdshell 'net use W: \\10.150.0.101\h$ Sq1s@fe! /User:GWRE-CLOUD\SQLsafe /PERSISTENT:yes'
go

OK           B:        \\10.150.0.101\H$         Microsoft Windows Network