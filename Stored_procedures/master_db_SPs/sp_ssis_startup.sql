USE [master]
GO

/****** Object:  StoredProcedure [dbo].[sp_ssis_startup]    Script Date: 7/30/2024 11:06:57 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



    CREATE PROCEDURE [dbo].[sp_ssis_startup]
    AS
    SET NOCOUNT ON
        /* Currently, the IS Store name is 'SSISDB' */
        IF DB_ID('SSISDB') IS NULL
            RETURN
        
        IF NOT EXISTS(SELECT name FROM [SSISDB].sys.procedures WHERE name=N'startup')
            RETURN
         
        /*Invoke the procedure in SSISDB  */
        EXEC [SSISDB].[catalog].[startup] 

GO

EXEC sp_procoption N'[dbo].[sp_ssis_startup]', 'startup', '1'

GO


