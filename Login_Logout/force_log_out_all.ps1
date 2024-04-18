# Get a list of all logged on users
$queryUsers = quser

if ($queryUsers -ne $null) {
    $queryUsers | ForEach-Object {
        # Skip the first line of output which is the header
        if ($_ -notmatch "USERNAME") {
            # Extract the session ID from each line
            $sessionId = ($_ -split '\s+')[2]

            # Log off the session
            logoff $sessionId
            Write-Output "Logged off session ID: $sessionId"
        }
    }
} else {
    Write-Output "No users currently logged on."
}
cccccbjfguhf