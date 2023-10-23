<#
##################################################################################################################
# Live Response Scripts
# 
# BackupSysmonLog.ps1
# v1.0 190314 Initial creation - Backs up the Sysmon logs
##################################################################################################################
#>

BEGIN
{
    $baseDirectory = "C:\WINDOWS\TEMP\" 
    $csvFilePath = $baseDirectory + "sysmonlog.csv"
    $zipFilePath = $baseDirectory + "sysmonlog.zip"
}
PROCESS
{
    # Query Sysmon logs and save them as sysmonlog.csv
    Get-WinEvent -LogName "Microsoft-Windows-Sysmon/Operational" | Export-Csv -Path $csvFilePath -NoTypeInformation

    # Compress the sysmonlog.csv file into sysmonlog.zip
    Compress-Archive -Path $csvFilePath -DestinationPath $zipFilePath -CompressionLevel Optimal -Force

    # Delete the sysmonlog.csv file after compression
    Remove-Item -Path $csvFilePath

    Write-Host "Sysmon logs compressed and saved to:"
    Write-Host $zipFilePath
}
END {}
