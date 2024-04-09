# Replace 'SQLSERVERAGENT' with the exact service name on your machine; this might vary, especially with named instances
$serviceName = "SQLSERVERAGENT"
$service = Get-Service -Name $serviceName

if ($service.Status -eq 'Running') {
    Write-Host "SQL Server Agent is running"
} else {
    Write-Host "SQL Server Agent is not running. Current status: $($service.Status)"
}
