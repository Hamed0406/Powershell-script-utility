# Display current date and time
$dateTimeNow = Get-Date
Write-Host "Current Date and Time: $dateTimeNow" -ForegroundColor Green

# CPU Usage
Write-Host "CPU Usage:" -ForegroundColor Cyan
Get-Counter -Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 1

# Memory Usage
Write-Host "Memory Usage:" -ForegroundColor Cyan
Get-Counter -Counter "\Memory\Available MBytes" -SampleInterval 1 -MaxSamples 1

# Disk Activity
Write-Host "Disk Activity:" -ForegroundColor Cyan
Get-Counter -Counter "\PhysicalDisk(_Total)\Disk Transfers/sec" -SampleInterval 1 -MaxSamples 1

# Network Utilization
Write-Host "Network Utilization:" -ForegroundColor Cyan
Get-Counter -Counter "\Network Interface(*)\Bytes Total/sec" -SampleInterval 1 -MaxSamples 1
