# Script to retrieve detailed information about all the groups a server belongs to, including nested groups
param(
    # Requires the name of the server as a mandatory parameter
    [Parameter(Mandatory = $true)]
    [string]$ServerName
)

# Importing the ActiveDirectory module for AD operations
Import-Module ActiveDirectory

# Retrieves AD computer object based on the server name
function Get-ServerADComputer {
    param([string]$ServerName)

    try {
        # Attempt to get the AD computer object; stop execution and throw an error if not found
        $Computer = Get-ADComputer -Identity $ServerName -ErrorAction Stop
    } catch {
        Write-Error "Unable to find computer account for '$ServerName'. Error: $_"
        exit
    }

    return $Computer
}

# Retrieves the manager of a group based on the 'ManagedBy' attribute
function Get-GroupManagedBy {
    param(
        [string]$ManagedBy
    )

    try {
        # Attempt to retrieve the display name of the manager; if not found, return a warning
        $Manager = Get-ADUser -Identity $ManagedBy -Properties DisplayName -ErrorAction Stop
        return $Manager.DisplayName
    } catch {
        Write-Warning "Could not find user with DN '$ManagedBy'. The user might be in a different domain or no longer exists."
        return "Not Found / Inaccessible"
    }
}

# Recursively retrieves all nested groups for a given AD object
function Get-NestedGroups {
    param(
        [string]$IdentityDistinguishedName, 
        [System.Collections.Generic.HashSet[string]]$ProcessedGroups
    )

    # Get direct group memberships for the AD object
    $DirectGroups = Get-ADPrincipalGroupMembership -Identity $IdentityDistinguishedName

    foreach ($Group in $DirectGroups) {
        # Check if the group has already been processed to avoid infinite loops
        if (-not $ProcessedGroups.Contains($Group.DistinguishedName)) {
            $ProcessedGroups.Add($Group.DistinguishedName) | Out-Null
            # Recursively call this function for nested groups
            Get-NestedGroups -IdentityDistinguishedName $Group.DistinguishedName -ProcessedGroups $ProcessedGroups
        }
    }
}

# Main script execution
# Retrieve the computer object for the specified server
$Computer = Get-ServerADComputer -ServerName $ServerName

# Initialize a hash set to track processed groups and avoid duplicates
$ProcessedGroups = New-Object 'System.Collections.Generic.HashSet[string]'

# Get all groups (including nested) for the computer object
Get-NestedGroups -IdentityDistinguishedName $Computer.DistinguishedName -ProcessedGroups $ProcessedGroups

# Collect and format detailed information for each group
$GroupObjects = foreach ($GroupDN in $ProcessedGroups) {
    $group = Get-ADGroup -Identity $GroupDN -Properties Description, ManagedBy, whenCreated, whenChanged
    $manager = if ($group.ManagedBy) { Get-GroupManagedBy -ManagedBy $group.ManagedBy } else { "Not Managed" }
    
    # Create a custom object for each group with detailed information
    [PSCustomObject]@{
        Name = $group.Name
        Description = $group.Description
        ManagedBy = $manager
        GroupScope = $group.GroupScope
        GroupCategory = $group.GroupCategory
        CreatedOn = $group.whenCreated
        LastModified = $group.whenChanged
    }
}

# Display the formatted table of group information
$GroupObjects | Format-Table -AutoSize
