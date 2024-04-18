# GetSSISEnvironmentVariables.ps1
# Description: This PowerShell script retrieves environment variables from a specified environment
# in the SSISDB catalog of SQL Server. It demonstrates how to query the SSISDB to obtain details
# about the environment variables configured within SSIS projects.

# First, ensure the SQLServer module is installed and imported. This module is required to use the Invoke-Sqlcmd cmdlet.
# You might need to run the command below if the module isn't already installed:
# Install-Module -Name SqlServer -AllowClobber -Scope CurrentUser

# Import the module in case it's not automatically loaded
Import-Module SqlServer

# Define your SQL Server instance and the SSISDB catalog. Replace placeholders with your actual server instance and environment name.
$sqlInstance = "YourServer\YourInstance"  # e.g., 'localhost', 'YourServer\YourInstance'
$database = "SSISDB"  # Default database for SSIS

# Specify the name of the environment within the SSISDB catalog from which to retrieve variables.
$environmentName = "production"

# SQL query to retrieve environment variables from the specified environment.
# Adjust the query if your setup differs from the standard SSISDB structure.
$query = @"
SELECT 
    env.name AS EnvironmentName, 
    var.name AS VariableName, 
    var.value AS VariableValue,
    var.description AS VariableDescription
FROM 
    [SSISDB].[catalog].[environments] AS env
INNER JOIN 
    [SSISDB].[catalog].[environment_variables] AS var ON env.environment_id = var.environment_id
WHERE 
    env.name = '$environmentName'
"@

# Execute the query against the specified SQL Server instance and database, then store the results.
$envVariables = Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $database -Query $query

# Iterate through each result and output the environment variable details to the terminal.
$envVariables | ForEach-Object {
    Write-Host "Environment: $($_.EnvironmentName) - Variable: $($_.VariableName), Value: $($_.VariableValue), Description: $($_.VariableDescription)"
}
