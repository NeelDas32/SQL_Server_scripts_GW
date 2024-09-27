-- Check the net use mapping
exec xp_cmdshell 'net use'
go

-- If W exist, drop it so it can be recreated
exec xp_cmdshell 'net use B: /delete'
go

-- recreate the mapping to the au1-bkp01 server
exec xp_cmdshell 'net use B: \\10.150.0.101\H$ S75myV7vGDwwggKJ /User:GWRE-CLOUD\icare-backup-user /PERSISTENT:yes'
go