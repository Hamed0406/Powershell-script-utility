# ReportFailedSqlAgentJobSteps.ps1
# Description: Queries a specified SQL Server Agent job to identify and report any steps that failed during its last execution.
# It leverages the SqlServer module to execute a T-SQL query against the msdb database, specifically targeting the job's history.

# Ensure the SqlServer module is available for SQL Server management tasks, providing functionality to execute T-SQL queries.
Import-Module SqlServer

# Specify the SQL Server instance and the name of the SQL Server Agent job to be examined.
# These placeholders should be replaced with the actual instance name and job name.
$sqlInstance = "YourSqlServerInstance"  # Example: 'localhost', 'YourServer\YourInstance'
$jobName = "YourJobName"  # The exact name of the SQL Server Agent job to check

# Construct a SQL query to retrieve information about any failed steps in the specified job's last run.
# The query focuses on steps with a run status indicating failure, excluding the job-level summary (step_id = 0).
$query = @"
SELECT j.name AS JobName,
       jh.step_id AS StepID,
       jh.step_name AS StepName,
       jh.sql_severity AS SqlSeverity,
       jh.message AS ErrorMessage,
       jh.run_status AS RunStatus,
       CASE jh.run_status WHEN 0 THEN 'Failed'
                          WHEN 1 THEN 'Succeeded'
                          WHEN 2 THEN 'Retry'
                          WHEN 3 THEN 'Canceled'
                          ELSE 'Unknown'
       END AS StatusDescription
FROM msdb.dbo.sysjobs j
JOIN msdb.dbo.sysjobhistory jh ON j.job_id = jh.job_id
WHERE j.name = '$jobName'
AND jh.run_status = 0  -- 0 indicates failure
AND jh.step_id != 0  -- step_id 0 is the job itself, not an individual step
ORDER BY jh.instance_id DESC
"@  # This query may need adjustments based on specific requirements.

# Execute the prepared query against the msdb database of the specified SQL Server instance.
$failedSteps = Invoke-Sqlcmd -ServerInstance $sqlInstance -Query $query -Database 'msdb'

# Evaluate the query results to determine if any job steps failed.
if ($failedSteps.Count -eq 0) {
    Write-Host "No failed steps found for the job '$jobName', or the job succeeded entirely."
} else {
    Write-Host "Failed step(s) for the job '$jobName':"
    $failedSteps | ForEach-Object {
        Write-Host "StepID: $($_.StepID), StepName: $($_.StepName), Error: $($_.ErrorMessage)"
    }
}
