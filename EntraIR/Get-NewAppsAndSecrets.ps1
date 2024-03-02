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
Write-Host "Newly Created App Credentials:"  -ForeGround DarkYellow
$filteredCredentials | Format-Table DisplayName, StartDateTime, EndDateTime, KeyId

# Retrieve all applications only once to optimize the process
$applications = Get-AzADApplication

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
