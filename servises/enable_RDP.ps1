# Set the Remote Desktop registry setting to enable RDP
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0

# Optional: Configure the Windows Firewall to allow RDP
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

Write-Output "Remote Desktop has been enabled. Please verify by attempting an RDP session."
