USE [GWRE_IT_NEW]
GO

/****** Object:  Table [dbo].[CPUUsage]    Script Date: 7/30/2024 11:10:32 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[CPUUsage](
	[SQLServer_CPU_Utilization] [int] NULL,
	[System_Idle_Process] [int] NULL,
	[Other_Process_CPU_Utilization] [int] NULL,
	[Event_Time] [datetime] NULL
) ON [PRIMARY]

GO


