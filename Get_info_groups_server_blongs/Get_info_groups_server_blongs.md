
# PowerShell Script Explanation

This PowerShell script is designed to retrieve detailed information about all the groups a server belongs to, including nested groups, within an Active Directory (AD) environment. It requires the server's name as a mandatory input parameter.

## Parameters

- **`$ServerName`**: This is a mandatory parameter that the user must provide when running the script. It specifies the name of the server for which the group information is to be retrieved.

## Importing Modules

- `Import-Module ActiveDirectory`: This line imports the ActiveDirectory module, which contains cmdlets for managing AD objects. This is necessary because the script performs operations such as fetching computer objects and group memberships from AD.

## Functions

1. **Get-ServerADComputer**
   - Retrieves the AD computer object for the server specified by `$ServerName`. It uses `Get-ADComputer` to fetch the computer object. If the computer cannot be found, it throws an error and stops the script execution.

2. **Get-GroupManagedBy**
   - Retrieves information about the manager of a group based on the 'ManagedBy' attribute of the group. It uses `Get-ADUser` to fetch the display name of the manager. If the manager's user account cannot be found, it issues a warning.

3. **Get-NestedGroups**
   - A recursive function that retrieves all groups, including nested groups, that the specified AD object (a server, in this context) belongs to. It uses `Get-ADPrincipalGroupMembership` to find direct group memberships and then recursively checks each group for further nested groups. A `HashSet` is used to track processed groups to avoid processing the same group more than once and prevent infinite loops.

## Main Script Execution

- The script retrieves the computer object for the specified server by calling `Get-ServerADComputer`.
- Initializes a `HashSet` to keep track of processed groups, ensuring each group is processed only once.
- Calls `Get-NestedGroups` to retrieve all groups (including nested groups) that the server belongs to.
- For each group found, the script gathers detailed information including the group's name, description, manager, group scope, category, creation date, and last modified date. The manager's name is retrieved using the `Get-GroupManagedBy` function.
- Creates a custom PowerShell object for each group with the collected information and displays a formatted table containing details of all groups.

## Summary

This script is useful for administrators who need to audit or review the group memberships of servers in their AD environment, including understanding the structure of nested group memberships. It leverages the PowerShell ActiveDirectory module to interact with AD and processes the data to present it in a user-friendly format.
