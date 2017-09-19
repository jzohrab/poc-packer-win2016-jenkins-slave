$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path "C:\provision.ps1.log" -append

# =========================================

# Install extra tools.
iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
choco install -y jre8 git

# Add MSBuild, set path
# (not using choco for this as it doesn't set the path correctly)
# From https://www.microsoft.com/en-us/download/details.aspx?id=48159
$msbuilddownload = "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe"
Invoke-WebRequest $msbuilddownload -OutFile "$env:TEMP\BuildTools_Full.exe" -UseBasicParsing
& "$env:TEMP\BuildTools_Full.exe" /Silent /Full

$msbuilddir = (Get-ItemProperty hklm:\software\Microsoft\MSBuild\ToolsVersions\4.0).MSBuildToolsPath
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$msbuilddir;$oldpath"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Jenkins swarm
$swarm_url = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.4/swarm-client-3.4.jar"
Invoke-WebRequest $swarm_url -OutFile "C:/swarm-client.jar" -UseBasicParsing

# =========================================

# Amazon EC2launch scripts:
# (ref http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html)

& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule

# SysprepInstance shuts down the AMI.
$set_exec_policy_cmd = 'powershell -ExecutionPolicy Bypass -NoProfile -c "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd $set_exec_policy_cmd
& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1

Stop-Transcript
