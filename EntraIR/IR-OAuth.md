# OAuth / Enterprise Apps

## Get-NewAppsBySecrets.ps1 - Az - Find New Secrets Created/Added to Applications and associate them with service Principals 
To check for newly created secrets and associate them with their apps and service principals all in one go, just use the script Get-NewAppsBySecrets.ps1 which combines all of the functionality below

```powershell
.\Get-NewAppsbySecrets.ps1 -DaysBack 90
```

## Az - Get Creation time of Apps and Secrets, get all service principals
```powershell
Install-Module -Name Az -AllowClobber -Scope CurrentUser

# Get Apps and Get Their Credentials to check the creation time of the app/secret
Get-AzADApplication|Get-AzADAppCredential

# Retrieve all service principals 
$servicePrincipals = Get-AzADServicePrincipal
```

## Az - Get App Credentials created in the last X days and associated service principals
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

## Az - Find App associated with KeyId of App credential
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

### AuditLogs / KQL - Detecting privilege escalation via changes to service principals
https://learnsentinel.blog/2022/01/04/azuread-privesc-sentinel/

<br>

# MicrosoftGraphActivityLogs - KQL to Query the Graph logs

## KQL - Azurehound Detection by Endpoints
A query that will look back for 35 minutes and summarize all Graph endpoints called by objectId requesting them. Then I calculate a confidence score based on how many of the Graph endpoints in my defined list are called and if this score is above a certain threshold, will return more information.

```kql
let AzureHoundGraphQueries = dynamic([
    "https://graph.microsoft.com/beta/servicePrincipals/<UUID>/owners",
    "https://graph.microsoft.com/beta/groups/<UUID>/owners",
    "https://graph.microsoft.com/beta/groups/<UUID>/members",
    "https://graph.microsoft.com/v1.0/servicePrincipals/<UUID>/appRoleAssignedTo",
    "https://graph.microsoft.com/beta/applications/<UUID>/owners",
    "https://graph.microsoft.com/beta/devices/<UUID>/registeredOwners",
    "https://graph.microsoft.com/v1.0/users",
    "https://graph.microsoft.com/v1.0/applications",
    "https://graph.microsoft.com/v1.0/groups",
    "https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments",
    "https://graph.microsoft.com/v1.0/roleManagement/directory/roleDefinitions",
    "https://graph.microsoft.com/v1.0/devices",
    "https://graph.microsoft.com/v1.0/organization",
    "https://graph.microsoft.com/v1.0/servicePrincipals"
    ]);
MicrosoftGraphActivityLogs
| where ingestion_time() > ago(35m)
| extend ObjectId = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend ObjectType = iff(isempty(UserId), "ServicePrincipalId", "UserId")
| where RequestUri !has "microsoft.graph.delta"
| extend NormalizedRequestUri = replace_regex(RequestUri, @'[0-9a-fA-F]{8}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{4}\b-[0-9a-fA-F]{12}', @'<UUID>')
| extend NormalizedRequestUri = replace_regex(NormalizedRequestUri, @'\?.*$', @'')
| summarize
    GraphEndpointsCalled = make_set(NormalizedRequestUri, 1000),
    IPAddresses = make_set(IPAddress)
    by ObjectId, ObjectType
| project
    ObjectId,
    ObjectType,
    IPAddresses,
    MatchingQueries=set_intersect(AzureHoundGraphQueries, GraphEndpointsCalled)
| extend ConfidenceScore = round(todouble(array_length(MatchingQueries)) / todouble(array_length(AzureHoundGraphQueries)), 1)
| where ConfidenceScore > 0.7
```

## KQL - AuditLogs for Delegated and Delegated Mail Permissions
```kql
AuditLogs
| where Category == "ApplicationManagement"
| where ActivityDisplayName in ("Add delegated permission grant", "Add app role assignment to service principal")
| mv-expand TargetResources
| where TargetResources.displayName == "Microsoft Graph"
| mv-expand TargetResources.modifiedProperties
| extend InitiatedByUserPrincipalName = InitiatedBy.user.userPrincipalName
| extend AddedPermission = replace_string(tostring(TargetResources_modifiedProperties.newValue),'"','')
| extend IP = todynamic(InitiatedBy).user.ipAddress
| extend ServicePrincipalAppId = replace_string(tostring(todynamic(TargetResources).modifiedProperties[5].newValue),'"','')
| where AddedPermission endswith ".All"
| project-reorder TimeGenerated, InitiatedByUserPrincipalName, ActivityDisplayName, AddedPermission, IP, ServicePrincipalAppId
```

```kql
AuditLogs
| where Category == "ApplicationManagement"
| where ActivityDisplayName in ("Add delegated permission grant", "Add app role assignment to service principal")
| mv-expand TargetResources
| where TargetResources.displayName == "Microsoft Graph"
| mv-expand TargetResources.modifiedProperties
| extend InitiatedByUserPrincipalName = tostring(InitiatedBy.user.userPrincipalName)
| extend AddedPermission = replace_string(tostring(TargetResources_modifiedProperties.newValue),'"','')
| extend IP = tostring(todynamic(InitiatedBy).user.ipAddress)
| extend ServicePrincipalAppId = iff(OperationName == "Add delegated permission grant", replace_string(tostring(todynamic(TargetResources).modifiedProperties[2].newValue),'"','') , replace_string(tostring(todynamic(TargetResources).modifiedProperties[5].newValue),'"',''))
| where AddedPermission has_all ("Mail", ".")
| summarize Permissions = make_set(AddedPermission) by ServicePrincipalAppId, IP, InitiatedByUserPrincipalName
| extend TotalPermissions = array_length(Permissions)
| project TotalPermissions, ServicePrincipalAppId, InitiatedByUserPrincipalName, IP, Permissions
| sort by TotalPermissions
```

## KQL - Detect AzureHound by UserAgent

```kql
MicrosoftGraphActivityLogs
| where UserAgent has "azurehound"
| extend ObjectId = iff(isempty(UserId), ServicePrincipalId, UserId)
| extend ObjectType = iff(isempty(UserId), "ServicePrincipalId", "UserId")
| summarize by ObjectId, ObjectType
```

Great EntraID Queries including BARK Research,= we have some of these implemented as Scheduled Queries:
https://github.com/reprise99/Sentinel-Queries/tree/main/Azure%20AD%20Abuse%20Detection


<br>

# Consent Grant Attacks / Delegated Permissions
Comprehensive with detection and blocking information
https://github.com/Cloud-Architekt/AzureAD-Attack-Defense/blob/main/ConsentGrant.md

Granting the correct way per-user using PwSh
https://github.com/MicrosoftDocs/entra-docs/blob/main/docs/identity/enterprise-apps/grant-consent-single-user.md

## Get-CRTReport.ps1 - Delegated Permissions, Check Mailbox Rules, Federation
```powershell
Get-CRTReport.ps1 # Sign-in as GA
```

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

