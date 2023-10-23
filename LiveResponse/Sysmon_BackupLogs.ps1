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
    $xmlFilePath = $baseDirectory + "sysmonlog.xml"
    $zipFilePath = $baseDirectory + "sysmonlog.zip"
}
PROCESS
{
    # Query Sysmon logs and save them as sysmonlog.xml
    WEVTUtil query-events "Microsoft-Windows-Sysmon/Operational" /format:xml /e:sysmonview > $xmlFilePath

    # Compress the sysmonlog.xml file into sysmonlog.zip
    Compress-Archive -Path $xmlFilePath -DestinationPath $zipFilePath -CompressionLevel Optimal -force

    # Delete the sysmonlog.xml file after compression
    Remove-Item -Path $xmlFilePath

    Write-Host "Sysmon logs compressed and saved to:"
    Write-Host $zipFilePath
}
END {}
