# Define the folder path
$folder = "~/Desktop/DFIR"

# If the folder doesn't exist, create it
if (-not (Test-Path $folder)) {
    New-Item -Path $folder -ItemType Directory
}

# Define a hashtable of URLs and their output file names for easier management
$downloads = @{
    'https://github.com/Velocidex/velociraptor/releases/download/v0.7.0/velociraptor-v0.7.0-rc1-windows-amd64.exe' = 'Velociraptor.exe';
    'https://github.com/hasherezade/hollows_hunter/releases/download/v0.3.6/hollows_hunter64.exe' = 'HollowsHunter.exe';
    'https://github.com/IppSec/PowerSiem/archive/refs/heads/master.zip' = 'powersiem.zip';
    'https://github.com/sans-blue-team/DeepBlueCLI/archive/refs/heads/master.zip' = 'deepblue.zip';
    'https://download.sysinternals.com/files/ProcessExplorer.zip' = 'ProcExp.zip';
    'https://download.sysinternals.com/files/ProcessMonitor.zip' = 'Procmon.zip';
    'https://github.com/decalage2/oletools/archive/refs/heads/master.zip' = 'oletools.zip';
    'https://download.sysinternals.com/files/SysinternalsSuite.zip' = 'sysinternals.zip';
    'https://github.com/mondogenerate/LiveResponse/archive/refs/heads/master.zip' = 'LiveResponse.zip';
    'https://github.com/mondogenerate/MDATP_PoSh_Scripts/archive/refs/heads/master.zip' = 'MDATP_Posh_Scripts.zip';
    'https://github.com/mondogenerate/Detections/archive/refs/heads/main.zip' = 'Detections.zip';
    'https://github.com/MelloSec/IPSee/archive/refs/heads/main.zip' = 'IPSee.zip';
}

# Download each file from the hashtable
$downloads.GetEnumerator() | ForEach-Object {
    $url = $_.Key
    $output = Join-Path -Path $folder -ChildPath $_.Value
    iwr $url -UseBasicParsing -OutFile $output
    
    # If the file is a zip, expand it
    if ($output -match '\.zip$') {
        Expand-Archive $output -DestinationPath $folder -Force
    }
}

# Live Response individual Scripts
# Hashtable of URLs and their output file names for Live Response scripts
$liveResponseScripts = @{
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/GetHostFile.ps1' = 'GetHostFile.ps1';
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/GetFirewallLogs.ps1' = 'GetFirewallLogs.ps1';
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/GetFirewallRules.ps1' = 'GetFirewallRules.ps1';
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/GetExternalIPAddress.ps1' = 'GetExternalIPAddress.ps1';
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/GetProcessMemoryDump.ps1' = 'GetProcessMemoryDump.ps1';
    'https://raw.githubusercontent.com/mondogenerate/LiveResponse/master/BackupEventlog.ps1' = 'BackupEventlog.ps1';
    'https://raw.githubusercontent.com/mondogenerate/MDATP_PoSh_Scripts/master/LiveResponse/Mem_Dump_2_Azure_Storage.ps1' = 'MemDump2Storage.ps1';
    'https://raw.githubusercontent.com/anthonws/MDATP_PoSh_Scripts/master/ASR/ASR_Analyzer_v2.2.ps1' = 'ASRAnalyzer.ps1';
}

# Scripts to exclude from execution
$excludeFromExecution = @('MemDump2Storage.ps1', 'ASRAnalyzer.ps1')

# Download each script from the hashtable and execute if not in exclusion list
$liveResponseScripts.GetEnumerator() | ForEach-Object {
    $url = $_.Key
    $output = Join-Path -Path $folder -ChildPath $_.Value
    iwr $url -UseBasicParsing -OutFile $output
    
    # Execute the script if it's not in the exclusion list
    if ($excludeFromExecution -notcontains $_.Value) {
        & $output
    }
}

# Download the onboard swift script and execute it
iwr https://raw.githubusercontent.com/mellonaut/sysmon/main/onboard_swift.ps1 -UseBasicParsing | iex

# Start Velociraptor after downloading
Start-Process "$folder\Velociraptor.exe"

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