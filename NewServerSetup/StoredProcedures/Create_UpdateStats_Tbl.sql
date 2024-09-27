USE [GWRE_IT]
GO

/****** Object:  Table [dbo].[UpdateStats]    Script Date: 08/31/2012 11:50:43 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[UpdateStats](
	[DATE] [datetime] NULL,
	[DB_NAME] [sysname] NOT NULL,
	[TABLE_NAME] [sysname] NOT NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO
