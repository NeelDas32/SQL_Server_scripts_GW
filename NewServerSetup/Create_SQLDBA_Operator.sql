USE [msdb]
GO

/****** Object:  Operator [SQLDBA]    Script Date: 06/17/2014 04:45:09 ******/
EXEC msdb.dbo.sp_add_operator @name=N'SQLDBA', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'cloudopsdba@guidewire.com', 
		@category_name=N'[Uncategorized]'
GO


