# Define your SQL Server instance and database
$sqlInstance = "oc233proddb" # e.g., 'localhost' or 'ServerName\InstanceName'
$database = "msdb" # SQL Server Agent status is typically queried from the msdb database

# SQL query to check the SQL Server Agent status
$query = "SELECT status_desc FROM sys.dm_server_services WHERE servicename LIKE '%SQL Server Agent%'"

# Running the SQL query
$result = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $database -Query $query

# Output the status
foreach ($row in $result) {
    Write-Host "SQL Server Agent Status: $($row.status_desc)"
}
