USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[IndexFragReport]    Script Date: 7/30/2024 11:10:56 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IndexFragReport](
	[DATE] [datetime] NULL,
	[DB_NAME] [sysname] NOT NULL,
	[SCHEMA_NAME] [sysname] NOT NULL,
	[TABLE_NAME] [sysname] NOT NULL,
	[INDEX_NAME] [sysname] NOT NULL,
	[FRAG] [float] NULL,
	[PAGES] [int] NULL,
	[ALLOWROWLOCKS] [varchar](5) NULL,
	[ALLOWPAGELOCKS] [varchar](5) NULL,
	[FILL_FACTOR] [int] NULL,
	[COMMAND] [varchar](8000) NULL,
	[ERROR_NUM] [int] NULL,
	[ERROR_MSG] [varchar](8000) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


