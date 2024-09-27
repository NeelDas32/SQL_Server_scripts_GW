USE [GWRE_IT]
GO

/****** Object:  Table [dbo].[IndexFrag]    Script Date: 11/29/2012 10:12:02 ******/
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IndexFrag]') AND type in (N'U'))
DROP TABLE [dbo].[IndexFrag]
GO

USE [GWRE_IT]
GO

/****** Object:  Table [dbo].[IndexFrag]    Script Date: 10/24/2012 11:19:46 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[IndexFrag](
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

