USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[CollectTablesize]    Script Date: 7/30/2024 11:10:27 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CollectTablesize](
	[DatabaseName] [sysname] NOT NULL,
	[TableName] [sysname] NOT NULL,
	[TotalRows] [bigint] NULL,
	[Totalspace(MB)] [decimal](18, 2) NULL,
	[UsedSpace(MB)] [decimal](18, 2) NULL,
	[UnusedSpace(MB)] [decimal](18, 2) NULL,
	[Rundate] [datetime] NOT NULL
) ON [PRIMARY]

GO


