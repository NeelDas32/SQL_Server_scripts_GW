USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[check_netuse_output]    Script Date: 7/30/2024 11:09:50 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[check_netuse_output](
	[Net_use] [varchar](400) NULL,
	[Run_Date] [datetime] NULL,
	[Executed_By] [nvarchar](100) NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


