# OAuth Apps

## Get-NewAppsBySecrets.ps1 - Az - Find New Secrets Created/Added to Applications and associate them with service Principals 
To check for newly created secrets and associate them with their apps and service principals all in one go, just use the script Get-NewAppsBySecrets.ps1 which combines all of the functionality below

```powershell
.\Get-NewAppsbySecrets.ps1 -DaysBack 90
```

## Az Module - Get Creation time of Apps and Secrets, get all service principals
```powershell
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Get Apps and Get Their Credentials to check the creation time of the app/secret
Get-AzADApplication|Get-AzADAppCredential

# Retrieve all service principals 
$servicePrincipals = Get-AzADServicePrincipal
```

## Az Module - Get App Credentials created in the last X days and associated service principals
```powershell
# Get App CredentialsCreated in the last X days
# Define the number of days back you want to filter
$DaysBack = 30 

# Calculate the target date from which to start filtering
$DateLimit = (Get-Date).AddDays(-$DaysBack)

# Retrieve all applications and their credentials
$allApps = Get-AzADApplication
$allCredentials = $allApps | Get-AzADAppCredential

# Filter credentials based on StartDateTime being within the last X days
$filteredCredentials = $allCredentials | Where-Object { $_.StartDateTime -gt $DateLimit }

# Display the filtered credentials
Write-Host "Newly Created App Credentials:"
$filteredCredentials | Format-Table DisplayName, StartDateTime, EndDateTime, KeyId
```

## Az Module - Find App associated with KeyId of App credential
```powershell
# Your target KeyId
$targetKeyId = "092a5430-ba98-4dbb-b797-b46ca254e32b"

# Retrieve all applications
$applications = Get-AzADApplication

# Initialize variable to store the matching application
$matchingApplication = $null

foreach ($app in $applications) {
    # Retrieve credentials for the current application
    $credentials = Get-AzADAppCredential -ApplicationId $app.AppId
    
    # Check if any credential matches the KeyId
    foreach ($cred in $credentials) {
        if ($cred.KeyId -eq $targetKeyId) {
            $matchingApplication = $app
            break
        }
    }
    
    # If a matching application was found, no need to continue checking
    if ($matchingApplication -ne $null) {
        break
    }
}

if ($matchingApplication -ne $null) {
    Write-Host "Found matching application: $($matchingApplication.DisplayName) with AppId: $($matchingApplication.AppId)"
    # Optionally, find and display the corresponding service principal
    $servicePrincipal = Get-AzADServicePrincipal -Filter "appId eq '$($matchingApplication.AppId)'"
    Write-Host "Corresponding Service Principal: $($servicePrincipal.DisplayName)"
} else {
    Write-Host "No matching application found for KeyId: $targetKeyId"
}
```

## AuditLogs / KQL - Detecting privilege escalation via changes to service principals
https://learnsentinel.blog/2022/01/04/azuread-privesc-sentinel/

<br>

# Consent Grant Attacks / Delegated Permissions
Comprehensive with detection and blocking information
https://github.com/Cloud-Architekt/AzureAD-Attack-Defense/blob/main/ConsentGrant.md

Granting the correct way per-user using PwSh
https://github.com/MicrosoftDocs/entra-docs/blob/main/docs/identity/enterprise-apps/grant-consent-single-user.md

## psignoret - Query Permissions granted to Service Principals
```powershell
iwr https://gist.githubusercontent.com/psignoret/9d73b00b377002456b24fcb808265c23/raw/7d2bd76a5fafc744bb9d920f8131c9dfb024a1df/Get-AzureADPSPermissionGrants.ps1 -o Get-AzureADPSPermissionGrants.ps1
iwr https://gist.githubusercontent.com/psignoret/9d73b00b377002456b24fcb808265c23/raw/7d2bd76a5fafc744bb9d920f8131c9dfb024a1df/Get-AzureADPSPermissions.ps1 -o Get-AzureADPSPermissions.ps1 

Connect-AzureAd

# View all delegated permissions
./Get-AzureADPSPermissions.ps1

# View Permission grants
Get-AzureADServicePrincipal -All $true | .\Get-AzureADPSPermissionGrants.ps1 -Preload
```
