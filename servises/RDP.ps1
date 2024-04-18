# Check Remote Desktop Services Status
$serviceStatus = Get-Service -Name TermService

# Check Remote Desktop Configuration
$regPath = "HKLM:\System\CurrentControlSet\Control\Terminal Server"
$rdpEnabled = Get-ItemProperty -Path $regPath -Name "fDenyTSConnections"

# Output the status of Remote Desktop Services
Write-Output "Remote Desktop Services (TermService) Status: $($serviceStatus.Status)"

# Determine if RDP is enabled or disabled
if ($rdpEnabled.fDenyTSConnections -eq 0) {
    Write-Output "Remote Desktop is ENABLED on this server."
} else {
    Write-Output "Remote Desktop is DISABLED on this server."
}

# Optional: Start the service if it's not running
if ($serviceStatus.Status -ne "Running") {
    Start-Service -Name TermService
    Write-Output "Remote Desktop Services (TermService) has been started."
}
