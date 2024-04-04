# PowerShell script for retrieving and exporting Active Directory group information

# Script Parameters
param(
    # Specifies the Active Directory group name to retrieve information for. This parameter is mandatory.
    [Parameter(Mandatory=$true)]
    [string]$GroupName,

    # Determines whether to export the retrieved group information to CSV files. Optional, defaults to false.
    [Parameter(Mandatory=$false)]
    [bool]$ExportToCsv = $false,

    # The file system path where export files will be saved if exporting is enabled. Optional, defaults to "C:\AD_Group_Info".
    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "C:\AD_Group_Info"
)

# Function to import the ActiveDirectory module. Necessary for AD operations.
function Import-ADModule {
    # Check if the ActiveDirectory module is available, exit if not found with an error message.
    if (-not(Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Error "ActiveDirectory module is not available. Please install RSAT tools."
        exit
    }
    Import-Module ActiveDirectory
}

# Function to get basic information about the specified AD group.
function Get-GroupBasicInfo {
    param(
        [string]$GroupName
    )

    Get-ADGroup -Identity $GroupName
}

# Function to get members of the specified AD group.
function Get-GroupMembers {
    param(
        [string]$GroupName
    )

    Get-ADGroupMember -Identity $GroupName
}

# Function to retrieve and optionally export detailed information about the specified AD group.
function Get-GroupDetailedInfo {
    param(
        [string]$GroupName,
        [string]$ExportPath,
        [bool]$ExportDetails
    )

    # Retrieve all properties of the AD group
    $group = Get-ADGroup -Identity $GroupName -Properties *
    # Organize the detailed information into a readable format
    $details = @(
        "Name: $($group.Name)",
        "Description: $($group.Description)",
        "Group Category: $($group.GroupCategory)",
        "Group Scope: $($group.GroupScope)",
        "Created On: $($group.whenCreated)",
        "Last Modified: $($group.whenChanged)",
        "Managed By: $(if ($group.ManagedBy) { (Get-ADUser -Identity $group.ManagedBy -Properties DisplayName).DisplayName } else { 'Not Managed' })",
        "Member Count: $(Get-ADGroupMember -Identity $GroupName | Measure-Object).Count",
        "Distinguished Name: $($group.DistinguishedName)",
        "Email: $($group.mail)",
        "Notes: $($group.info)"
    )

    # Export details to a file or display them based on $ExportDetails flag
    if ($ExportDetails) {
        $dateStamp = Get-Date -Format "yyyy-MM-dd"
        $detailsPath = Join-Path -Path $ExportPath -ChildPath "${GroupName}_Details_$dateStamp.txt"
        $details | Out-File -FilePath $detailsPath
        Write-Host "Detailed group information exported to '$detailsPath'"
    } else {
        foreach ($detail in $details) {
            Write-Host $detail
        }
    }
}

# Function to export basic group information and member list to CSV files.
function Export-GroupInfoToCsv {
    param(
        [string]$GroupName,
        [string]$ExportPath
    )

    # Generate a timestamp for file naming
    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    # Sanitize the group name for use in a filename
    $sanitizedGroupName = $GroupName -replace '[^\w\d]', '_'
    # Retrieve basic info and members
    $basicInfo = Get-GroupBasicInfo -GroupName $GroupName
    $members = Get-GroupMembers -GroupName $GroupName

    # Prepare file paths for exporting
    $basicInfoPath = Join-Path -Path $ExportPath -ChildPath "${sanitizedGroupName}_BasicInfo_$dateStamp.csv"
    $membersPath = Join-Path -Path $ExportPath -ChildPath "${sanitizedGroupName}_Members_$dateStamp.csv"

    # Export to CSV files
    $basicInfo | Export-Csv -Path $basicInfoPath -NoTypeInformation
    $members | Export-Csv -Path $membersPath -NoTypeInformation

    Write-Host "Exported group information to '$ExportPath'"
}

# Main script execution starts here

# Import the necessary Active Directory module
Import-ADModule

# Ensure the export directory exists, create if not
if (-not(Test-Path -Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath | Out-Null
}

# Retrieve and display or export detailed group information
Write-Host "Retrieving and displaying detailed information for group: $GroupName"
Get-GroupDetailedInfo -GroupName $GroupName -ExportPath $ExportPath -ExportDetails $ExportToCsv

# If exporting to CSV is enabled, perform the export
if ($ExportToCsv) {
    Write-Host "Exporting basic information and members list to CSV files."
    Export-GroupInfoToCsv -GroupName $GroupName -ExportPath $ExportPath
}
