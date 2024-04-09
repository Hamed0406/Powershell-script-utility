# StartMonitorSqlAgentJob.ps1
# Description: Initiates a specified SQL Server Agent job on a designated SQL Server instance
# and monitors its execution status in real time. It provides status updates until the job completes
# or is otherwise stopped, including a final report on the job's outcome.

# Ensure the SqlServer module is available for managing SQL Server entities.
Import-Module SqlServer

# Specify the SQL Server instance and the name of the SQL Server Agent job to be started and monitored.
$sqlInstance = "YourSqlServerInstance"  # Example: 'localhost', 'YourServer\YourInstance'
$jobName = "YourJobName"  # The exact name of the SQL Server Agent job

# Establish a connection to the specified SQL Server instance.
$server = New-Object Microsoft.SqlServer.Management.Smo.Server($sqlInstance)

# Start the designated SQL Server Agent job.
$job = $server.JobServer.Jobs[$jobName]
$job.Start()
Write-Host "Job '$jobName' has been started on '$sqlInstance'."

# Define a function to assess and return the current status of the job as a readable string.
function Get-JobStatus {
    param ($job)
    
    switch ($job.CurrentRunStatus) {
        ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Executing) { "running" }
        ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Idle) { "not running" }
        ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::BetweenRetries) { "waiting to retry" }
        ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Suspended) { "suspended" }
        default { "unknown" }
    }
}

# Continuously monitor and report the job's status at 5-second intervals,
# until the job is no longer in a running state.
do {
    Start-Sleep -Seconds 5
    $job.Refresh()
    $status = Get-JobStatus -job $job
    Write-Host "Current status of the job '$jobName': $status"
} while ($status -eq "running" -or $status -eq "waiting to retry")

# Provide a final report on the outcome of the job's last execution.
$job.Refresh()
switch ($job.LastRunOutcome) {
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Succeeded) { Write-Host "The job '$jobName' completed successfully." }
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Failed) { Write-Host "The job '$jobName' failed." }
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Canceled) { Write-Host "The job '$jobName' was canceled." }
    default { Write-Host "The job '$jobName' has an unknown outcome." }
}
