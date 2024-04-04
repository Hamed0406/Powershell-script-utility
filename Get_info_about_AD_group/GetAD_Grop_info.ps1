param(
    [Parameter(Mandatory=$true)]
    [string]$GroupName,

    [Parameter(Mandatory=$false)]
    [bool]$ExportToCsv = $false,

    [Parameter(Mandatory=$false)]
    [string]$ExportPath = "C:\AD_Group_Info"
)

function Import-ADModule {
    if (-not(Get-Module -ListAvailable -Name ActiveDirectory)) {
        Write-Error "ActiveDirectory module is not available. Please install RSAT tools."
        exit
    }
    Import-Module ActiveDirectory
}

function Get-GroupBasicInfo {
    param(
        [string]$GroupName
    )

    Get-ADGroup -Identity $GroupName
}

function Get-GroupMembers {
    param(
        [string]$GroupName
    )

    Get-ADGroupMember -Identity $GroupName
}

function Get-GroupDetailedInfo {
    param(
        [string]$GroupName,
        [string]$ExportPath,
        [bool]$ExportDetails
    )

    $group = Get-ADGroup -Identity $GroupName -Properties *
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

function Export-GroupInfoToCsv {
    param(
        [string]$GroupName,
        [string]$ExportPath
    )

    $dateStamp = Get-Date -Format "yyyy-MM-dd"
    $sanitizedGroupName = $GroupName -replace '[^\w\d]', '_'
    $basicInfo = Get-GroupBasicInfo -GroupName $GroupName
    $members = Get-GroupMembers -GroupName $GroupName

    $basicInfoPath = Join-Path -Path $ExportPath -ChildPath "${sanitizedGroupName}_BasicInfo_$dateStamp.csv"
    $membersPath = Join-Path -Path $ExportPath -ChildPath "${sanitizedGroupName}_Members_$dateStamp.csv"

    $basicInfo | Export-Csv -Path $basicInfoPath -NoTypeInformation
    $members | Export-Csv -Path $membersPath -NoTypeInformation

    Write-Host "Exported group information to '$ExportPath'"
}

# Script execution starts here
Import-ADModule

if (-not(Test-Path -Path $ExportPath)) {
    New-Item -ItemType Directory -Path $ExportPath | Out-Null
}

Write-Host "Retrieving and displaying detailed information for group: $GroupName"
Get-GroupDetailedInfo -GroupName $GroupName -ExportPath $ExportPath -ExportDetails $ExportToCsv

if ($ExportToCsv) {
    Write-Host "Exporting basic information and members list to CSV files."
    Export-GroupInfoToCsv -GroupName $GroupName -ExportPath $ExportPath
}
