USE [msdb]
GO

/****** Object:  Job [Copy Backups to S3]    Script Date: 7/29/2024 11:51:22 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 7/29/2024 11:51:22 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Copy Backups to S3', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQLDBA', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Backups to S3 - System DBs]    Script Date: 7/29/2024 11:51:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Backups to S3 - System DBs', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$erroractionpreference = "Stop"
$s3bucket = "s3://043662530543-is-icare-preprod-dbbackups-ap-southeast-2"
$region = "--region=ap-southeast-2"

$day = (get-date)
$yr = $day.Year.ToString()
$mo = $day.Month.ToString()
$dy = $day.day.ToString()
if ($mo.Length -eq 1){
    $mo = "0" + $mo
}
if ($dy.Length -eq 1){
    $dy = "0" + $dy
}

$fday = $yr + $mo + $dy

$fday = "*" + $fday + "*"
echo $fday

$Path = "filesystem::F:\MSSQL\Backup"
$PathArray = @()

echo $PATH

Get-ChildItem $Path -Filter $fday -Recurse |
Where-Object { $_.Attributes -ne "Directory"} |
ForEach-Object {

$PathArray += $_.FullName

}


echo $PathArray

$body = "The following files were backed up to S3 `n"
foreach ($fname in $PathArray) {
    
echo $fname

    $a = $fname.Substring(15,$fname.Length - 15)
    $a = $a.Replace("\", "/")
    $target = $s3bucket + $a
    echo $target
    $env:Path += '';C:\Program Files\Amazon\AWSCLI''

    $cmd = "& aws s3 cp $fname $target $region --sse --storage-class STANDARD_IA"

    $targetexist = aws s3 ls $target $region
    echo $targetexist
    
    if (-Not $targetexist) {
    # write-host $fname
        Invoke-Expression $cmd
        echo $cmd
        $body += "`n"
        $body += $fname
    }

   
}', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\Copy_to_s3_SystemDB.txt', 
		@flags=0, 
		@proxy_name=N'Powershell_proxy_account'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Backups to S3 - User DBs except GWPreProd]    Script Date: 7/29/2024 11:51:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Backups to S3 - User DBs except GWPreProd', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$erroractionpreference = "Stop"
$s3bucket = "s3://043662530543-is-icare-preprod-dbbackups-ap-southeast-2/"
$region = "--region=ap-southeast-2"

$day = (get-date)
$yr = $day.Year.ToString()
$mo = $day.Month.ToString()
$dy = $day.day.ToString()
if ($mo.Length -eq 1){
    $mo = "0" + $mo
}
if ($dy.Length -eq 1){
    $dy = "0" + $dy
}

$fday = $yr + $mo + $dy

$fday = "*" + $fday + "*"
echo $fday

$Path = "filesystem::\\10.150.0.101\H$\NonProdDbBackups\PreProd\"
$PathArray = @()

echo $PATH

Get-ChildItem $Path -Filter $fday -Recurse |
Where-Object { $_.Attributes -ne "Directory"} |
ForEach-Object {

$PathArray += $_.FullName

}


echo $PathArray

$body = "The following files were backed up to S3 `n"
foreach ($fname in $PathArray) {
    
echo $fname

    $a = $fname.Substring(15,$fname.Length - 15)
    $a = $a.Replace("\", "/")
    $target = $s3bucket + $a
    echo $target
    $env:Path += '';C:\Program Files\Amazon\AWSCLI''

    $cmd = "& aws s3 cp $fname $target $region --sse --storage-class STANDARD_IA"

    $targetexist = aws s3 ls $target $region
    echo $targetexist
    
    if (-Not $targetexist) {
    # write-host $fname
        Invoke-Expression $cmd
        echo $cmd
        $body += "`n"
        $body += $fname
    }

   
}', 
		@database_name=N'master', 
		@output_file_name=N'F:\SQLJobLogs\Copy_to_s3_UserDB.txt', 
		@flags=0, 
		@proxy_name=N'Powershell_proxy_account'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Copy Backups to S3 - User GWPreProd DBs only]    Script Date: 7/29/2024 11:51:22 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Copy Backups to S3 - User GWPreProd DBs only', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'PowerShell', 
		@command=N'$erroractionpreference = "Stop"
$s3bucket = "s3://043662530543-is-icare-preprod-dbbackups-ap-southeast-2/"
$region = "--region=ap-southeast-2"

$day = (get-date)
$yr = $day.Year.ToString()
$mo = $day.Month.ToString()
$dy = $day.day.ToString()
if ($mo.Length -eq 1){
    $mo = "0" + $mo
}
if ($dy.Length -eq 1){
    $dy = "0" + $dy
}

$fday = $yr + $mo + $dy

$fday = "*" + $fday + "*"
echo $fday

$Path = "filesystem::\\10.150.0.101\h$\NonProdDbBackups\PreProd_gwpreprod\"
$PathArray = @()

echo $PATH

Get-ChildItem $Path -Filter $fday -Recurse |
Where-Object { $_.Attributes -ne "Directory"} |
ForEach-Object {

$PathArray += $_.FullName

}


echo $PathArray

$body = "The following files were backed up to S3 `n"
foreach ($fname in $PathArray) {
    
echo $fname

    $a = $fname.Substring(15,$fname.Length - 15)
    $a = $a.Replace("\", "/")
    $target = $s3bucket + $a
    echo $target
    $env:Path += '';C:\Program Files\Amazon\AWSCLI''

    $cmd = "& aws s3 cp $fname $target $region --sse --storage-class STANDARD_IA"

    $targetexist = aws s3 ls $target $region
    echo $targetexist
    
    if (-Not $targetexist) {
    # write-host $fname
        Invoke-Expression $cmd
        echo $cmd
        $body += "`n"
        $body += $fname
    }

   
}', 
		@database_name=N'master', 
		@flags=0, 
		@proxy_name=N'Powershell_proxy_account'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220217, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'11ad1d95-70a2-4aa3-a332-8b2e76611063'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO


