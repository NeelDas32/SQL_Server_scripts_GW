USE [msdb]
GO

/****** Object:  Job [Forcing Execution plan at server start]    Script Date: 7/29/2024 11:56:00 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:56:00 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Forcing Execution plan at server start', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'ICAREPREPROD\sqlsa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [PolPeriodPolicyClosureGuide]    Script Date: 7/29/2024 11:56:00 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'PolPeriodPolicyClosureGuide', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'declare @xml_showplan nvarchar(max);
set @xml_showplan = ''<ShowPlanXML xmlns="http://schemas.microsoft.com/sqlserver/2004/07/showplan" Version="1.480" Build="12.0.6164.21"><BatchSequence><Batch><Statements><StmtSimple StatementText="SELECT /* KeyTable:bc_policyperiod; */ qRoot.ID col0 FROM bc_policyperiod qRoot INNER JOIN bc_policy policy_0 ON policy_0.ID = qRoot.PolicyID WHERE qRoot.ClosureStatus &lt;&gt; @P0 AND qRoot.Retired = 0 AND policy_0.AccountID = @P1 AND policy_0.Retired = 0" StatementId="1" StatementCompId="1" StatementType="SELECT" RetrievedFromCache="true" StatementSubTreeCost="0.02375" StatementEstRows="6.16846" StatementOptmLevel="FULL" QueryHash="0x56C2AA6EF4ADA476" QueryPlanHash="0x51D82303FC9DD0FE" StatementOptmEarlyAbortReason="GoodEnoughPlanFound" CardinalityEstimationModelVersion="70"><StatementSetOptions QUOTED_IDENTIFIER="true" ARITHABORT="false" CONCAT_NULL_YIELDS_NULL="true" ANSI_NULLS="true" ANSI_PADDING="true" ANSI_WARNINGS="true" NUMERIC_ROUNDABORT="false"/><QueryPlan CachedPlanSize="32" CompileTime="3" CompileCPU="3" CompileMemory="496"><MemoryGrantInfo SerialRequiredMemory="512" SerialDesiredMemory="544"/><OptimizerHardwareDependentProperties EstimatedAvailableMemoryGrant="655360" EstimatedPagesCached="655360" EstimatedAvailableDegreeOfParallelism="4" MaxCompileMemory="63044416"/><TraceFlags IsCompileTime="1"><TraceFlag Value="2861" Scope="Global"/><TraceFlag Value="3226" Scope="Global"/><TraceFlag Value="4199" Scope="Global"/><TraceFlag Value="9481" Scope="Global"/></TraceFlags><RelOp NodeId="0" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="6.16846" EstimateIO="0" EstimateCPU="2.57842e-005" AvgRowSize="19" EstimatedTotalSubtreeCost="0.02375" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></OutputList><MemoryFractions Input="0" Output="1"/><NestedLoops Optimized="1"><OuterReferences><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></OuterReferences><RelOp NodeId="2" PhysicalOp="Nested Loops" LogicalOp="Inner Join" EstimateRows="6.16846" EstimateIO="0" EstimateCPU="2.57842e-005" AvgRowSize="15" EstimatedTotalSubtreeCost="0.00659767" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></OutputList><NestedLoops Optimized="0"><OuterReferences><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="ID"/></OuterReferences><RelOp NodeId="3" PhysicalOp="Index Seek" LogicalOp="Index Seek" EstimateRows="1" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="15" EstimatedTotalSubtreeCost="0.0032831" TableCardinality="494972" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="ID"/></OutputList><IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="ID"/></DefinedValue></DefinedValues><Object Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Index="[bc0000008lN2]" Alias="[policy_0]" IndexKind="NonClustered" Storage="RowStore"/><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="AccountID"/><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="Retired"/></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[@P1]"><Identifier><ColumnReference Column="@P1"/></Identifier></ScalarOperator><ScalarOperator ScalarString="(0)"><Const ConstValue="(0)"/></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp><RelOp NodeId="4" PhysicalOp="Index Seek" LogicalOp="Index Seek" EstimateRows="6.16846" EstimateIO="0.003125" EstimateCPU="0.000163785" AvgRowSize="15" EstimatedTotalSubtreeCost="0.00328879" TableCardinality="3.05313e+006" Parallel="0" EstimateRebinds="0" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></OutputList><IndexScan Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues><DefinedValue><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></DefinedValue></DefinedValues><Object Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Index="[bc000000dpN21]" Alias="[qRoot]" IndexKind="NonClustered" Storage="RowStore"/><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="PolicyID"/><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="Retired"/></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[prod_bc].[dbo].[bc_policy].[ID] as [policy_0].[ID]"><Identifier><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policy]" Alias="[policy_0]" Column="ID"/></Identifier></ScalarOperator><ScalarOperator ScalarString="(0)"><Const ConstValue="(0)"/></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates></IndexScan></RelOp></NestedLoops></RelOp><RelOp NodeId="6" PhysicalOp="Clustered Index Seek" LogicalOp="Clustered Index Seek" EstimateRows="6.16846" EstimateIO="0.003125" EstimateCPU="0.0001581" AvgRowSize="11" EstimatedTotalSubtreeCost="0.0171265" TableCardinality="3.05313e+006" Parallel="0" EstimateRebinds="5.16846" EstimateRewinds="0" EstimatedExecutionMode="Row"><OutputList/><IndexScan Lookup="1" Ordered="1" ScanDirection="FORWARD" ForcedIndex="0" ForceSeek="0" ForceScan="0" NoExpandHint="0" Storage="RowStore"><DefinedValues/><Object Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Index="[bc_policyperiod_PK]" Alias="[qRoot]" TableReferenceId="-1" IndexKind="Clustered" Storage="RowStore"/><SeekPredicates><SeekPredicateNew><SeekKeys><Prefix ScanType="EQ"><RangeColumns><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></RangeColumns><RangeExpressions><ScalarOperator ScalarString="[prod_bc].[dbo].[bc_policyperiod].[ID] as [qRoot].[ID]"><Identifier><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ID"/></Identifier></ScalarOperator></RangeExpressions></Prefix></SeekKeys></SeekPredicateNew></SeekPredicates><Predicate><ScalarOperator ScalarString="[prod_bc].[dbo].[bc_policyperiod].[ClosureStatus] as [qRoot].[ClosureStatus]&lt;&gt;[@P0]"><Compare CompareOp="NE"><ScalarOperator><Identifier><ColumnReference Database="[prod_bc]" Schema="[dbo]" Table="[bc_policyperiod]" Alias="[qRoot]" Column="ClosureStatus"/></Identifier></ScalarOperator><ScalarOperator><Identifier><ColumnReference Column="@P0"/></Identifier></ScalarOperator></Compare></ScalarOperator></Predicate></IndexScan></RelOp></NestedLoops></RelOp><ParameterList><ColumnReference Column="@P1" ParameterCompiledValue="(326721)"/><ColumnReference Column="@P0" ParameterCompiledValue="(1)"/></ParameterList></QueryPlan></StmtSimple></Statements></Batch></BatchSequence></ShowPlanXML>''

select @xml_showplan
EXEC sp_create_plan_guide
@name = N''PolPeriodPolicyClosureGuide'',
@stmt = N''
SELECT
/* KeyTable:bc_policyperiod; */
qRoot.ID col0
FROM bc_policyperiod qRoot
INNER JOIN bc_policy policy_0
ON policy_0.ID = qRoot.PolicyID
WHERE qRoot.ClosureStatus <> @P0
AND qRoot.Retired = 0
AND policy_0.AccountID = @P1
AND policy_0.Retired = 0'',
@type = N''SQL'',
@module_or_batch = NULL,
@params = N''@P0 int, @P1 bigint'',
@hints = @xml_showplan;



--EXEC sp_control_plan_guide N''DROP'', ''PolPeriodPolicyClosureGuide'';  
--GO 
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'On server restartes', 
		@enabled=1, 
		@freq_type=64, 
		@freq_interval=0, 
		@freq_subday_type=0, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220204, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'f108bbf5-d91b-4d5d-a066-7cd58555290f'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


