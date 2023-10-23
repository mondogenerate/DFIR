<#
##################################################################################################################
# BackupPowerShellLog.ps1
# Backs up the Windows PowerShell log
##################################################################################################################
#>

$baseDirectory = "C:\WINDOWS\TEMP\" 
$csvFilePath = $baseDirectory + "PowerShellLog.csv"
$zipFilePath = $baseDirectory + "PowerShellLog.zip"

# Query the Windows PowerShell log and save as CSV
Get-WinEvent -LogName "Windows PowerShell" | Export-Csv -Path $csvFilePath -NoTypeInformation

# Compress the CSV into a ZIP file
Compress-Archive -Path $csvFilePath -DestinationPath $zipFilePath -CompressionLevel Optimal -Force

# Delete the CSV file after compression
Remove-Item -Path $csvFilePath

Write-Host "Windows PowerShell log compressed and saved to:"
Write-Host $zipFilePath
