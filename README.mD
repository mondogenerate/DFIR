## DFIR Resources

# AzureAD IR Cheatsheet
https://14518100.fs1.hubspotusercontent-na1.net/hubfs/14518100/Cheat%20Sheets/Azure%20Incident%20Response%20Cheat%20Sheet.pdf

#### SocMonkey Cheatsheets
https://s0cm0nkey.gitbook.io/s0cm0nkeys-security-reference-guide/dfir-digital-forensics-and-incident-response
https://s0cm0nkey.gitbook.io/s0cm0nkeys-security-reference-guide/blue-defense

### Sysmon Tools
https://github.com/mellonaut/SysmonTools

### Sentinel Queries
https://github.com/Azure/Azure-Sentinel/blob/master/Solutions/Windows%20Security%20Events/Hunting%20Queries/CommandsexecutedbyWMIonnewhosts-potentialImpacket.yaml

### KQL for DFIR
https://techcommunity.microsoft.com/t5/microsoft-security-experts-blog/leveraging-the-power-of-kql-in-incident-response/ba-p/3044795
https://github.com/reprise99/kql-for-dfir

### Great Breakdows of AAD IR / Official Module with KQL
https://github.com/reprise99/kql-for-dfir/tree/main/Azure%20Active%20Directory
https://github.com/reprise99/kql-for-dfir/blob/main/Combined%20Queries/README.md
https://github.com/reprise99/kql-for-dfir/blob/main/Office%20365/README.md

### Windows and AD
https://github.com/reprise99/kql-for-dfir/blob/main/Windows/README.md
https://github.com/reprise99/kql-for-dfir/blob/main/Active%20Directory/README.md

### KQL - The logs you DONT have
https://kqlquery.com/posts/kql-incident-response-everything-else/

## Initial Investigations
Run our automated investigation tools first to see what picks up before we dive into KQL or endpoint

# Sparrow - CISA IR Script - 
# Dashboard - https://github.com/cisagov/Sparrow/releases/download/v1.0/aviary.xml
$modules = @('AzureAD', 'MSOnline', 'ExchangeOnlineManagement', 'Microsoft.Graph')
foreach ($module in $modules) {
    # Check if the module is installed
    if (-not (Get-Module -ListAvailable -Name $module)) {
        # Install the module
        Write-Host "Installing $module..."
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }

    # Check if the module is imported
    if (-not (Get-Module -Name $module)) {
        # Import the module
        Write-Host "Importing $module..."
        Import-Module -Name $module
    } else {
        Write-Host "$module is already imported."
    }
}
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
Invoke-WebRequest 'https://github.com/cisagov/Sparrow/raw/develop/Sparrow.ps1' -OutFile 'Sparrow.ps1' -UseBasicParsing; .\Sparrow.ps1




# Hawk - IR Script https://cloudforensicator.com/documentation
Set-ExecutionPolicy RemoteSigned
Install-Module -Name Hawk
Install-Module -Name ExchangeOnlineManagement
Import-Module ExchangeOnlineManagement
Connect-AzureAD
Connect-MsolService
Connect-ExchangeOnline
Start-HawkTenantInvestigation




# AzureAd IR Module - Best Documentation : https://github.com/reprise99/kql-for-dfir/tree/main/Azure%20Active%20Directory
$user = "rmattingly@anchorconst.com"
Install-Module -Name AzureADIncidentResponse -AcceptLicense -Force
Import-Module -Name AzureADIncidentResponse -Force
$tenant = Get-AzureADIRTenantId
Connect-AzureADIR $tenant
Get-AzureADIRDomainRegistrationDetail $tenant
# CA and MFA
Get-AzureADIRConditionalAccessPolicy -all $tenant
Get-AzureADIRMfaAuthMethodAnalysis $tenant 
Get-AzureADIRMfaPhoneToLocationCheck $tenant
# permissions
Get-AzureADIRPermission $tenant
Get-AzureADIRPrivilegedRoleAssignment $tenant
Get-AzureADIRPimPrivilegedRoleAssignment $tenant -all
Get-AzureADIRPimPrivilegedRoleAssignmentRequest $tenant
# Users
Get-AzureADIRUserLastSignInActivity $tenant -all
Get-AzureADIRDismissedUserRisk $tenant
# User context
Get-AzureADIRSignInDetail $tenant $user
Get-AzureADIRAuditActivity $tenant $user
# GAdmin / AD RSAT required
Get-AzureADIRPrivilegedUserOnPremCorrelation $tenant
Get-AzureADIRSsprUsageHistory $tenant




# Mandiant - IR Powershell Module
$modules = @('AzureAD', 'MSOnline', 'ExchangeOnlineManagement', 'Microsoft.Graph')
foreach ($module in $modules) {
    # Check if the module is installed
    if (-not (Get-Module -ListAvailable -Name $module)) {
        # Install the module
        Write-Host "Installing $module..."
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }

    # Check if the module is imported
    if (-not (Get-Module -Name $module)) {
        # Import the module
        Write-Host "Importing $module..."
        Import-Module -Name $module
    } else {
        Write-Host "$module is already imported."
    }
}
Import-Module .\MandiantAzureADInvestigator.psd1

$user = "rmattingly@anchorconst.com"
Connect-MandiantAzureEnvironment -UserPrincipalName $user
mkdir .\MandiantResults
Invoke-MandiantAllChecks -OutputPath "."
$directoryPath = ".\MandiantResults"
# Check if the directory exists
if (-not (Test-Path $directoryPath)) {
    # Create the directory if it doesn't exist
    mkdir $directoryPath
}
Invoke-MandiantAllChecks -OutputPath $directoryPath




# Crowdstrike Reporting Tool - IR Script
$modules = @('AzureAD', 'ExchangeOnlineManagement')
foreach ($module in $modules) {
    # Check if the module is installed
    if (-not (Get-Module -ListAvailable -Name $module)) {
        # Install the module
        Write-Host "Installing $module..."
        Install-Module -Name $module -Force -AllowClobber -Scope CurrentUser
    }

    # Check if the module is imported
    if (-not (Get-Module -Name $module)) {
        # Import the module
        Write-Host "Importing $module..."
        Import-Module -Name $module
    } else {
        Write-Host "$module is already imported."
    }
}
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
Invoke-WebRequest 'https://raw.githubusercontent.com/CrowdStrike/CRT/main/Get-CRTReport.ps1' -Outfile 'Get-CRTReport.ps1' -UseBasicParsing; .\Get-CRTReport.ps1
