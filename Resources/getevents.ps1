# See if logs folder exists or makes it
$path = "C:\hunt\logs\"
If(!(test-path $path))
{
      New-Item -ItemType Directory -Force -Path $path
}

# Housekeeping including varialbes for days of log we want back, level of logging and whether this is being run locally or remotely
Set-Variable -Name EventAgeDays -Value 14
Set-Variable -Name LogNames -Value @("Application", "System", "Security")  # Checking app and system logs
Set-Variable -Name EventTypes -Value @("Error", "Warning")  # Loading only Errors and Warnings
Set-Variable -Name ExportFolder -Value "C:\hunt\logs\"
Set-Variable -Name CompArr -Value $env:computername
# Set-Variable -Name CompArr -Value @("SERV1", "SERV2", "SERV3", "SERV4")   # for remote array replace it with your server names

$el_c = @()   #consolidated error log
$now=get-date
$startdate=$now.adddays(-$EventAgeDays)
$ExportFile=$ExportFolder + "el" + $now.ToString("yyyy-MM-dd---hh-mm-ss") + ".csv"  # we cannot use standard delimiteds like ":"

# Main loop, moving through our array and selecting logs/level we asked for in the housekeeping section
foreach($comp in $CompArr)
{
  foreach($log in $LogNames)
  {
    Write-Host Processing $comp\$log
    $el = get-eventlog -ComputerName $comp -log $log -After $startdate -EntryType $EventTypes
    $el_c += $el  #consolidating
  }
}
# Sort the consolidated logs
$el_sorted = $el_c | Sort-Object TimeGenerated    #sort by time
Write-Host Exporting to $ExportFile
$el_sorted|Select EntryType, TimeGenerated, Source, EventID, MachineName | Export-CSV $ExportFile -NoTypeInfo  #EXPORT
Write-Host Get to Greppin.