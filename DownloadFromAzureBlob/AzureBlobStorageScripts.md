
# Azure Blob Storage File Retrieval Scripts

This repository contains two PowerShell scripts designed to interact with Azure Blob Storage containers. These scripts allow you to list blob items in a container and download them to a local directory.

## Scripts Overview

- `Get-BlobItems`: Lists all items in a specified Azure Blob Storage container.
- `Invoke-BlobItems`: Downloads all items from a specified Azure Blob Storage container to a local directory.

## Usage

### Parameters

Both scripts require the following parameter:

- `$URL`: The full URL to the Azure Blob Storage container, including the Shared Access Signature (SAS) token.

`Invoke-BlobItems` also uses:

- `$Path`: The local directory path where blob items will be downloaded. Defaults to `D:\DownloadfromBlob`.

### Get-BlobItems

To list all items in a container:

\```powershell
Get-BlobItems -URL "<Container_URL_With_SAS_Token>"
\```

### Invoke-BlobItems

To download all items from a container to the specified directory:

\```powershell
Invoke-BlobItems -URL "<Container_URL_With_SAS_Token>" -Path "<Local_Directory_Path>"
\```

## Script Details

### Get-BlobItems

This script constructs a REST API URL to list the contents of the specified Azure Blob Storage container. It then parses the XML response to extract and return the download URLs for each blob item, including the SAS token.

### Invoke-BlobItems

This script, similar to `Get-BlobItems`, lists all items in the specified container. It then iterates over each item, creates the necessary local directory structure, and downloads the files to the specified local directory.

## Prerequisites

- PowerShell 5.1 or higher
- Access to an Azure Blob Storage container and a valid SAS token

## Security Note

Ensure that your SAS token is kept secure and is not exposed in scripts or repositories.
