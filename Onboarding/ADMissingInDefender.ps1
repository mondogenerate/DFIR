# Devices in AD that are Not Onboarded to Defender for Endpoint

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

# Import devices from CSV
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

 
# Extract additional details from the original Defender CSV
$missingDetails = $notInDefenderDetails | ForEach-Object {
    $currentDevice = $_.Name
    $defenderInfo = $defenderDevices | Where-Object { $_.'Device Name'.Trim() -eq $currentDevice }

 

    [PSCustomObject]@{
        'Device Name' = $currentDevice;
        'OS Version'  = $defenderInfo.'OS Version'; # Adjust the column name based on your CSV
        'Last Seen'   = $defenderInfo.'Last Seen';  # Adjust the column name based on your CSV
        # Add more columns if necessary
    }
}

 

# Output the results to console
$missingDetails | Format-Table

 

# Save these results to a file
$missingDetails | Export-Csv "MissingInDefender.csv" -NoTypeInformation


# Import intune.csv
$intuneDevices = Import-Csv -Path "intune.csv"

# # Correlate with devices not in Defender
# $correlatedDetails = $notInDefender | ForEach-Object {
#     $currentDeviceName = $_
#     $intuneInfo = $intuneDevices | Where-Object { $_.'Device name'.Trim() -eq $currentDeviceName }

#     if ($intuneInfo) {
#         [PSCustomObject]@{
#             'Device Name'          = $currentDeviceName;
#             'Primary user UPN'     = $intuneInfo.'Primary user UPN';
#             'Join Type'            = $intuneInfo.'JoinType';
#             'Last check-in'        = $intuneInfo.'Last check-in';
#             'Manufacturer'         = $intuneInfo.'Manufacturer';
#         }
#     }
# }

# # Output the correlated results to console
# $correlatedDetails | Format-Table

# # Save these correlated results to a file
# $correlatedDetails | Export-Csv "CorrelatedMissingInDefender.csv" -NoTypeInformation




