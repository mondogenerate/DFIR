Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install NuGet provider without prompt
# Install-PackageProvider -Name PsGet -Force -Scope CurrentUser
powershell -ep bypass Install-Module PSWindowsUpdate -Force
powershell -ep bypass Import-Module PSWindowsUpdate -Force
powershell -ep bypass Install-WindowsUpdate -AutoReboot -AcceptAll

# Packages
choco install vscode git poshgit -y
choco install firefox chrome fiddler -y
choco install checksum -y
choco install 7zip.install -y
choco install processhacker -y
choco install procmon -y
choco install sysinternals -y
choco install notmyfault -y
choco install tcpview -y
choco install golang -y
choco install vscode -y
choco install sysinternals -y
choco install hxd -y
choco install pebear -y
choco install pestudio --ignore-checksums
choco install pesieve -y
choco install HollowsHunter -y
choco install dnspy -y
choco install dotpeek -y
choco install nxlog -y
choco install x64dbg.portable -y
choco install ollydbg -y
choco install ida-free -y
choco install cutter -y
choco install openjdk11 -y
setx -m JAVA_HOME "C:\Program Files\Java\jdk-11.0.2\"
choco install ghidra -y

# WSL
# Enable the WSL feature
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux

# Enable the Virtual Machine Platform feature (for WSL 2)
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform

# Enable the WSL feature
wsl --install

wsl --set-default-version 2

# Download and install Ubuntu 20.04 LTS
Invoke-WebRequest -Uri https://aka.ms/wslubuntu2004 -OutFile Ubuntu.appx -UseBasicParsing
Add-AppxPackage .\Ubuntu.appx


