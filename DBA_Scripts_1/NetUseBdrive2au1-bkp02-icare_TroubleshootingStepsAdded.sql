--(1) Check the net use mapping
exec xp_cmdshell 'net use'
go

--(2) If W exist, drop it so it can be recreated
exec xp_cmdshell 'net use W: /delete'
go

--(3) recreate the mapping to the au1-bkp01 server
exec xp_cmdshell 'net use W: \\10.150.0.101\H$ S75myV7vGDwwggKJ /User:GWRE-CLOUD\icare-backup-user /PERSISTENT:yes'
go


--------------------------------------
-- Troubleshoot --
-- system error 1219 has occurred. net use
-- Open cmd prompt in administrator mode
-- Run the below.
-- C:\Windows\system32> net use * /del
-- You have these remote connections:
--
-- Do you want to continue this operation? (Y/N) [N]: y
-- The command completed successfully.
--
-- Below should return empty.
-- C:\Windows\system32> net use
--
-- Then, execute the (3) from above now to re-create mapping.
--------------------------------------



