<#
.SYNOPSIS
This script retrieves newly created Azure AD application credentials within a specified number of days and matches them with their corresponding applications and service principals. It will show new secrets added to new or existing applications based on StartTime and find the app and principal. Helps to find newly registered apps or privilege escalation on existing ones.

.DESCRIPTION
The script filters Azure AD application credentials based on their creation date, showing only those created within the last X days as specified by the user. It then correlates these credentials with their respective Azure AD applications and the corresponding service principals by matching the KeyId of the credentials.

.PARAMETER DaysBack
The number of days back from the current date to filter newly created credentials. Credentials created within this time frame will be displayed.

.EXAMPLE
.\Get-NewAppsBySecrets.ps1 -DaysBack 30
This example retrieves and displays all Azure AD application credentials created in the last 30 days and matches them with their applications and service principals.

.EXAMPLE
$30 | .\Get-NewAppsBySecrets.ps1.ps1
This example shows how to pass the DaysBack value through the pipeline, achieving the same result as the first example.

.NOTES
Author: mellonaut
Date: 3/2/2024
# Requires -Modules Az

#>

param (
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [int]$DaysBack
)

# Calculate the target date from which to start filtering
$DateLimit = (Get-Date).AddDays(-$DaysBack)

# Retrieve all applications and their credentials
$allApps = Get-AzADApplication
$allCredentials = $allApps | Get-AzADAppCredential

# Filter credentials based on StartDateTime being within the last X days
$filteredCredentials = $allCredentials | Where-Object { $_.StartDateTime -gt $DateLimit }

# Display the filtered credentials
Write-Host "Newly Created App Credentials:"  -ForeGround DarkBlue
$filteredCredentials | Format-Table DisplayName, StartDateTime, EndDateTime, KeyId

# Use the previously retrieved Applications again to speed things up
$applications = $allApps

Write-Host "Correlating filtered Application Credentials w/ Apps and Service Principals." -ForeGround DarkBlue
foreach ($cred in $filteredCredentials) {
    $targetKeyId = $cred.KeyId
    $matchingApplication = $null

    foreach ($app in $applications) {
        # Retrieve credentials for the current application
        $appCredentials = Get-AzADAppCredential -ApplicationId $app.AppId
        
        # Check if any of the application's credentials match the KeyId
        $matchingCredential = $appCredentials | Where-Object { $_.KeyId -eq $targetKeyId }
        
        if ($matchingCredential) {
            $matchingApplication = $app
            break
        }
    }
    
    if ($matchingApplication) {
        Write-Host "Found matching application for KeyId $targetKeyId`: $(${matchingApplication}.DisplayName) with AppId: $(${matchingApplication}.AppId)"  -ForeGround DarkYellow
        
        # Find the corresponding service principal
        $servicePrincipal = Get-AzADServicePrincipal -Filter "appId eq '$($matchingApplication.AppId)'"
        if ($servicePrincipal) {
            Write-Host "Corresponding Service Principal: $($servicePrincipal.DisplayName)"  -ForeGround DarkYellow
        } else {
            Write-Host "No corresponding service principal found." -ForeGround DarkYellow
        }
    } else {
        Write-Host "No matching application found for KeyId: $targetKeyId"
    }
}
