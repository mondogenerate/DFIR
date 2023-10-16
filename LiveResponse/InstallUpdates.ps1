# Apply Windows Updates using PSWindowsUpdate module
# Ensure the PSWindowsUpdate module is installed
Install-Module -Name PSWindowsUpdate -Force -AllowClobber -Scope CurrentUser

# Install updates
Get-WindowsUpdate -Install -AcceptAll -AutoReboot

# Wait for a few minutes to allow updates to be applied
Start-Sleep -Seconds 3000 

# Forcefully shut down the computer
Stop-Computer -Force

