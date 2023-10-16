# Devices in AD that are Not Onboarded to Defender for Endpoint
# Export Defender devices as devices.csv
# This will get all AD Computers, compare them to Onboarded Defender devices
# Devices that are in AD, but not in Defender 
# Then correlate with intune.csv 

# Import the necessary module
Import-Module ActiveDirectory

# Export Devices from M365 Defender Portal under 'Devices'
# Import devices from CSV
$defenderDevices = Import-Csv -Path ".\devices.csv"

# Extract device names
$defenderDeviceNames = $defenderDevices | ForEach-Object { $_.'Device Name'.Trim() } 

# Import the necessary module
Import-Module ActiveDirectory

# Retrieve all computer objects from AD
$adComputers = Get-ADComputer -Filter *

# Extract the names of the computers
$adComputerNames = $adComputers | ForEach-Object { $_.Name }

# Find devices in AD but not in Defender
$notInDefender = $adComputerNames | Where-Object { $_ -notin $defenderDeviceNames }

# Output the results
$notInDefender | ForEach-Object { Write-Output "Present in AD but not in Defender: $_" }

# If you want to save these results to a file
$notInDefender | Out-File "MissingInDefender.txt"

# Import Defender devices from CSV you exported from the portal
$defenderDevices = Import-Csv -Path "devices.csv"

# Extract device names based on the "Device Name" column
$defenderDeviceNames = $defenderDevices | ForEach-Object { $_."Device Name" }

# Retrieve all computer objects from AD
$adComputers = Get-ADComputer -Filter *

# Extract the names of the computers
$adComputerNames = $adComputers | ForEach-Object { $_.Name }

# Find devices in AD but not in Defender
$notInDefender = $adComputerNames | Where-Object { $_ -notin $defenderDeviceNames }

# Output the results
$notInDefender | ForEach-Object { Write-Output "Present in AD but not in Defender: $_" }

# If you want to save these results to a file
# $notInDefender | Out-File "MissingInDefender.txt"

# Find devices in AD but not in Defender
$notInDefenderDetails = $adComputers | Where-Object { $_.Name -notin $defenderDeviceNames }

 


 

# Output the results to console
$missingDetails | Format-Table

 

# Save these results to a file
$missingDetails | Export-Csv "MissingInDefender.csv" -NoTypeInformation


# Import intune.csv
$intuneDevices = Import-Csv -Path "intune.csv"

# Correlate with devices not in Defender
$correlatedDetails = $notInDefender | ForEach-Object {
    $currentDeviceName = $_
    $intuneInfo = $intuneDevices | Where-Object { $_.'Device name'.Trim() -eq $currentDeviceName }

    if ($intuneInfo) {
        [PSCustomObject]@{
            'Device Name'          = $currentDeviceName;
            'Primary user UPN'     = $intuneInfo.'Primary user UPN';
            'Join Type'            = $intuneInfo.'JoinType';
            'Ownership'            = $intuneInfo.'Ownership';
            'Last check-in'        = $intuneInfo.'Last check-in';            
            'Manufacturer'         = $intuneInfo.'Manufacturer';
            'Enrollment Date'      = $intuneInfo.'Enrollment Date';
            'DeviceId'             = $intuneInfo.'Device ID';

        }
    }
}

# Output the correlated results to console
$correlatedDetails | Format-Table

# Save these correlated results to a file
$correlatedDetails | Export-Csv "CorrelatedMissingInDefender.csv" -NoTypeInformation




