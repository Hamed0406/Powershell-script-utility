enter-pssession# CheckSqlAgentJobStatus.ps1
# Description: This script checks the status of a specified SQL Server Agent job on a given SQL Server instance.
# It reports the job's current running status and the outcome of its last execution, providing insights into
# job performance and troubleshooting issues.

# Import the SqlServer module to use its functionality for executing SQL Server management tasks.
# The module includes cmdlets and functions for working with SQL Server, including the SQL Server Agent.
Import-Module SqlServer

# Define the SQL Server instance where the job is scheduled and the name of the job to check.
# Update these placeholder values to reflect your specific SQL Server environment and job name.
$sqlInstance = "YourServer\YourInstance"  # Example: 'localhost', 'YourServer\YourInstance'
$jobName = "jobName"  # The name of the SQL Server Agent job to check

# Establish a connection to the specified SQL Server instance by creating a Server object.
# This object provides access to the server and its properties, including the SQL Server Agent jobs.
$server = New-Object Microsoft.SqlServer.Management.Smo.Server($sqlInstance)

# Retrieve the job object for the specified job name to access its properties and methods.
$job = $server.JobServer.Jobs[$jobName]

# Verify if the specified job exists on the server. If not, output a message and exit the script.
if ($job -eq $null) {
    Write-Host "Job '$jobName' was not found on instance '$sqlInstance'."
    return
}

# Check and display the job's current running status.
# The status indicates whether the job is executing, idle, waiting to retry, or suspended.
switch ($job.CurrentRunStatus) {
    ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Executing) { Write-Host "The job '$jobName' is currently running." }
    ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Idle) { Write-Host "The job '$jobName' is not currently running." }
    ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::BetweenRetries) { Write-Host "The job '$jobName' is waiting to retry." }
    ([Microsoft.SqlServer.Management.Smo.Agent.JobExecutionStatus]::Suspended) { Write-Host "The job '$jobName' is suspended." }
    default { Write-Host "The job '$jobName' has an unknown status." }
}

# Additionally, report on the outcome of the job's last run, indicating whether it succeeded, failed, or was canceled.
# This information is helpful for monitoring job performance and identifying issues.
switch ($job.LastRunOutcome) {
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Succeeded) { Write-Host "The last run of the job '$jobName' succeeded." }
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Failed) { Write-Host "The last run of the job '$jobName' failed." }
    ([Microsoft.SqlServer.Management.Smo.Agent.CompletionResult]::Canceled) { Write-Host "The last run of the job '$jobName' was canceled." }
    default { Write-Host "The last run of the job '$jobName' has an unknown outcome." }
}
