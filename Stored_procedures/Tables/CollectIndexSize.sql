USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[CollectIndexSize]    Script Date: 7/30/2024 11:10:21 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[CollectIndexSize](
	[ServerName] [sysname] NOT NULL,
	[DbName] [sysname] NOT NULL,
	[SchemaName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[IndexId] [int] NULL,
	[IndexType] [varchar](12) NULL,
	[IndexName] [sysname] NOT NULL,
	[IndexSizeMb] [int] NULL,
	[ReportDate] [datetime] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


