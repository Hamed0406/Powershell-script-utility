# Get a list of all logged in users using the quser command
try {
    $userSessions = quser 2>$null  # Redirect errors to null to handle cases where no one is logged in

    if ($userSessions -ne $null) {
        # Skip the first line which is the header
        $userSessions | Select-Object -Skip 1 | ForEach-Object {
            # Split each line into parts and clean up the output
            $sessionDetails = $_ -replace '\s+', ',' -split ','
            # Extract relevant details
            $userName = $sessionDetails[0]
            $sessionType = $sessionDetails[1]
            $idleTime = $sessionDetails[3]
            $logonTime = $sessionDetails[4]

            # Display formatted user session information
            Write-Output "User: $userName, Session Type: $sessionType, Idle Time: $idleTime, Logon Time: $logonTime"
        }
    } else {
        Write-Output "No users are currently logged in."
    }
} catch {
    Write-Error "Failed to retrieve logged-in users: $_"
}
