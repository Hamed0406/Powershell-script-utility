# Restart Remote Desktop Services (TermService)
try {
    # Attempt to stop the service
    Stop-Service -Name TermService -Force -PassThru
    Write-Output "Remote Desktop Services stopping..."

    # Wait a moment to ensure the service stops properly
    Start-Sleep -Seconds 5

    # Attempt to start the service
    Start-Service -Name TermService -PassThru
    Write-Output "Remote Desktop Services started successfully."
} catch {
    Write-Error "Error occurred while restarting Remote Desktop Services: $_"
}
