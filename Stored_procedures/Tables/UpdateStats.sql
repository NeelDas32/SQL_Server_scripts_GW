USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[UpdateStats]    Script Date: 7/30/2024 11:11:01 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[UpdateStats](
	[DATE] [datetime] NULL,
	[DB_NAME] [sysname] NOT NULL,
	[TABLE_NAME] [sysname] NOT NULL
) ON [PRIMARY]

GO


