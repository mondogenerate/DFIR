param(
    [Parameter(Mandatory=$false)]
    [string]$CsvPath
)
# Import the CSV file
$devices = Import-Csv -Path $CsvPath

# Filter devices that have checked in during 2023
$checkedIn2023 = $devices | Where-Object {
    $checkinDate = [DateTime]::Parse($_.'Last check-in')
    $checkinDate.Year -eq 2023
}

# Display the results
$checkedIn2023 | Format-Table

# If you wish to save these results to another CSV
$checkedIn2023 | Export-Csv "CheckedInThisYear.csv" -NoTypeInformation

# $checkedIn2023 | ConvertTo-Html -Title "Devices Checked-In in 2023" | Out-File "CheckedInThisYear.html"
$checkedIn2023 | Sort-Object 'Last check-in' -Descending | ConvertTo-Html -Title "Devices Checked-In in 2023" | Out-File "CheckedInThisYear.html"
