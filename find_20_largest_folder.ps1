<#
2024-02-16
find 20 largest folder on drive . 
it is usefull for cleanup , it take sometime to script be completed . 
#>

# Define the drive or path you want to scan
$drivePath = "C:\Users\" 

# Get the list of all folders in the drive
$folders = Get-ChildItem -Path $drivePath -Directory -Recurse -ErrorAction SilentlyContinue

# Initialize an array to hold folder sizes
$folderSizes = @()

foreach ($folder in $folders) {
    # Calculate the size of each folder
    $size = Get-ChildItem -Path $folder.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
    $folderSize = New-Object PSObject -Property @{
        "Path" = $folder.FullName
        "Size" = $size.Sum
    }
    $folderSizes += $folderSize
}

# Sort the folders by size (largest first) and select the top 20
$largestFolders = $folderSizes | Sort-Object -Property Size -Descending | Select-Object -First 20

# Display the results
$largestFolders | Format-Table Path, @{Name="Size(GB)";Expression={$_.Size / 1GB}} -AutoSize
