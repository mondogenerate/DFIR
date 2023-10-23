<#
##################################################################################################################
# BackupSecurityLog.ps1
# Backs up the Security log
##################################################################################################################
#>

$baseDirectory = "C:\WINDOWS\TEMP\" 
$csvFilePath = $baseDirectory + "SecurityLog.csv"
$zipFilePath = $baseDirectory + "SecurityLog.zip"

# Query the Security log and save as CSV
Get-WinEvent -LogName "Security" | Export-Csv -Path $csvFilePath -NoTypeInformation

# Compress the CSV into a ZIP file
Compress-Archive -Path $csvFilePath -DestinationPath $zipFilePath -CompressionLevel Optimal -Force

# Delete the CSV file after compression
Remove-Item -Path $csvFilePath

Write-Host "Security log compressed and saved to:"
Write-Host $zipFilePath
