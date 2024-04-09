# UpdateSSISEnvironmentVariable.ps1
# Description: This script updates the value of a specified environment variable within an environment
# in the SSISDB catalog of SQL Server. It's useful for modifying SSIS project configurations programmatically.

# Import the SqlServer module. This is required to use the Invoke-Sqlcmd cmdlet for executing SQL queries.
# Ensure the SQLServer module is installed. If not, you can install it using PowerShell's Install-Module cmdlet.
Import-Module SqlServer

# Define the SQL Server instance where the SSISDB catalog resides. Update the placeholders to match your environment.
$sqlInstance = "YourSqlServerInstance"  # Example: 'localhost' or 'YourServer\YourInstance'
$database = "SSISDB"  # The default database for Integration Services

# Specify the environment and the variable within the SSISDB catalog you wish to update.
$environmentName = "YourEnvironmentName"  # The name of the SSIS environment
$variableName = "YourVariableName"  # The name of the variable to update
$newValue = "NewVariableValue"  # The new value for the variable. Ensure correct formatting, especially for string values.

# Construct the SQL query to update the environment variable's value.
# This query finds the environment by name, then updates the specified variable within that environment.
$query = @"
DECLARE @environment_id INT = (SELECT environment_id FROM [SSISDB].[catalog].[environments] WHERE name = '$environmentName')
UPDATE [SSISDB].[catalog].[environment_variables]
SET value = '$newValue'
WHERE environment_id = @environment_id AND name = '$variableName'
"@

# Execute the query against the SQL Server instance and the SSISDB database.
Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $database -Query $query

# Output a confirmation message indicating the update was successful.
Write-Host "Environment variable '$variableName' within environment '$environmentName' has been updated to '$newValue'."
