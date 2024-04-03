


function Get-BlobItems{
    param (
        $URL
    )
    
    $uri = $URL.split('?')[0]
    $sas = $URL.split('?')[1]
    
    $newurl = $uri + "?restype=container&comp=list&" + $sas 
    
    #Invoke REST API
    $body = Invoke-RestMethod -uri $newurl

    #cleanup answer and convert body to XML
    $xml = [xml]$body.Substring($body.IndexOf('<'))

    #use only the relative Path from the returned objects
    $files = $xml.ChildNodes.Blobs.Blob.Name

    #regenerate the download URL incliding the SAS token
    $files | ForEach-Object { $uri + "/" + $_ + "?" + $sas }    
}


function Invoke-BlobItems {
    param (
        [Parameter(Mandatory)]
        [string]$URL,
        [string]$Path = ("D:\DownloadfromBlob")
    )
    
    $uri = $URL.split('?')[0]
    $sas = $URL.split('?')[1]

    $newurl = $uri + "?restype=container&comp=list&" + $sas 
    
    #Invoke REST API
    $body = Invoke-RestMethod -uri $newurl

    #cleanup answer and convert body to XML
    $xml = [xml]$body.Substring($body.IndexOf('<'))

    #use only the relative Path from the returned objects
    $files = $xml.ChildNodes.Blobs.Blob.Name

    #create folder structure and download files
    $files | ForEach-Object { $_; New-Item (Join-Path $Path (Split-Path $_)) -ItemType Directory -ea SilentlyContinue | Out-Null
        (New-Object System.Net.WebClient).DownloadFile($uri + "/" + $_ + "?" + $sas, (Join-Path $Path $_))
     }
}

