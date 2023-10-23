<#
##################################################################################################################
# BackupApplicationLog.ps1
# Backs up the Application log
##################################################################################################################
#>

$baseDirectory = "C:\WINDOWS\TEMP\" 
$csvFilePath = $baseDirectory + "ApplicationLog.csv"
$zipFilePath = $baseDirectory + "ApplicationLog.zip"

# Query the Application log and save as CSV
Get-WinEvent -LogName "Application" | Export-Csv -Path $csvFilePath -NoTypeInformation

# Compress the CSV into a ZIP file
Compress-Archive -Path $csvFilePath -DestinationPath $zipFilePath -CompressionLevel Optimal -Force

# Delete the CSV file after compression
Remove-Item -Path $csvFilePath

Write-Host "Application log compressed and saved to:"
Write-Host $zipFilePath
