function Get-BlobItems{
    param (
        # The URL to the Azure Blob Storage container, including the SAS token
        $URL
    )
    
    # Splitting the URL to separate the base URI from the SAS token
    $uri = $URL.split('?')[0]
    $sas = $URL.split('?')[1]
    
    # Constructing a new URL to list the contents of the container
    $newurl = $uri + "?restype=container&comp=list&" + $sas 
    
    # Invoking the REST API to list the contents of the container
    $body = Invoke-RestMethod -uri $newurl

    # Cleaning up the response and converting the body to XML format for easier parsing
    $xml = [xml]$body.Substring($body.IndexOf('<'))

    # Extracting the relative paths of the items in the container
    $files = $xml.ChildNodes.Blobs.Blob.Name

    # Regenerating the download URLs for each item, including the SAS token
    $files | ForEach-Object { $uri + "/" + $_ + "?" + $sas }    
}

function Invoke-BlobItems {
    param (
        # The URL to the Azure Blob Storage container, including the SAS token. This parameter is mandatory.
        [Parameter(Mandatory)]
        [string]$URL,
        # The local path where the blob items will be downloaded. Defaults to "D:\DownloadfromBlob".
        [string]$Path = ("D:\DownloadfromBlob")
    )
    
    # Splitting the URL to separate the base URI from the SAS token
    $uri = $URL.split('?')[0]
    $sas = $URL.split('?')[1]

    # Constructing a new URL to list the contents of the container
    $newurl = $uri + "?restype=container&comp=list&" + $sas 
    
    # Invoking the REST API to list the contents of the container
    $body = Invoke-RestMethod -uri $newurl

    # Cleaning up the response and converting the body to XML format for easier parsing
    $xml = [xml]$body.Substring($body.IndexOf('<'))

    # Extracting the relative paths of the items in the container
    $files = $xml.ChildNodes.Blobs.Blob.Name

    # Creating the folder structure as needed and downloading the files
    $files | ForEach-Object {
        $_; 
        New-Item (Join-Path $Path (Split-Path $_)) -ItemType Directory -ea SilentlyContinue | Out-Null
        (New-Object System.Net.WebClient).DownloadFile($uri + "/" + $_ + "?" + $sas, (Join-Path $Path $_))
    }
}
