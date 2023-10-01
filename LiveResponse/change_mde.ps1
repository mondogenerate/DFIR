# One-Liner for Deployment:
# iwr https://raw.githubusercontent.com/mondogenerate/sysmon/main/change_mde.ps1 -UseBasic  | iex
$fileName = "onboard_mde"
Write-Output "Triggered new script"
powershell Set-ExecutionPolicy Bypass
if(Test-Path C:\sysmon){ Remove-Item  -r c:\sysmon -Force}
mkdir "C:\sysmon";
Invoke-WebRequest -Uri "https://github.com/mondogenerate/sysmon/raw/main/$fileName.zip" -OutFile "C:\sysmon\$fileName.zip" -UseBasicParsing;
Expand-Archive "c:\sysmon\$fileName.zip" -DestinationPath "C:\sysmon";
cd "c:\sysmon";
c:\sysmon\sysmon.exe -acceptEula -c c:\sysmon\$fileName.xml
Write-Output "Cleaning up artifacts.."
Remove-Item c:\sysmon\$fileName.xml
Remove-Item c:\sysmon\$fileName.zip
Remove-Item c:\sysmon\$fileName.ps1
Remove-Item C:\Sysmon\*.zip
Remove-Item C:\Sysmon\*.xml