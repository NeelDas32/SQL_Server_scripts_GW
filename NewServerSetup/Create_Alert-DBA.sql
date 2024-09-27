USE [msdb]
GO

/****** Object:  Operator [Alert-DBA]    Script Date: 06/10/2016 09:49:59 ******/
IF  EXISTS (SELECT name FROM msdb.dbo.sysoperators WHERE name = N'Alert-DBA')
EXEC msdb.dbo.sp_delete_operator @name=N'Alert-DBA'
GO

USE [msdb]
GO

/****** Object:  Operator [Alert-DBA]    Script Date: 06/10/2016 09:49:59 ******/
EXEC msdb.dbo.sp_add_operator @name=N'Alert-DBA', 
		@enabled=1, 
		@weekday_pager_start_time=0, 
		@weekday_pager_end_time=235959, 
		@saturday_pager_start_time=0, 
		@saturday_pager_end_time=235959, 
		@sunday_pager_start_time=0, 
		@sunday_pager_end_time=235959, 
		@pager_days=127, 
		@email_address=N'cloudopsdba-911@guidewire.com;', 
		@pager_address=N'cloudopsdba-911@guidewire.com;', 
		@category_name=N'[Uncategorized]'
GO

