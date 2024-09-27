USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[DatabaseSize]    Script Date: 7/30/2024 11:10:36 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DatabaseSize](
	[DatabaseName] [sysname] NOT NULL,
	[DateRecorded] [datetime] NULL,
	[SizeMB] [decimal](18, 2) NULL
) ON [PRIMARY]

GO


