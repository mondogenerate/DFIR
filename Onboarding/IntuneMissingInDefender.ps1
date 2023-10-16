# Import intune.csv
$intuneDevices = Import-Csv -Path "intune.csv"

# Filter out devices with ownership "Personal"
# $intuneDevices = $intuneDevices | Where-Object { $_.Ownership -ne 'Personal' }


# Extract device names from intune.csv
$intuneDeviceNames = $intuneDevices | ForEach-Object { $_.'Device name'.Trim() }

# Import devices.csv (from Defender)
$defenderDevices = Import-Csv -Path "devices.csv"

# Extract device names from devices.csv
$defenderDeviceNames = $defenderDevices | ForEach-Object { $_.'Device Name'.Trim() }

# Find devices in Intune but not in Defender
$notInDefender = $intuneDeviceNames | Where-Object { $_ -notin $defenderDeviceNames }

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
$correlatedDetails | Export-Csv "IntuneMissingInDefender.csv" -NoTypeInformation
