<powershell>

write-output "Running User Data Script"
write-host "(host) Running User Data Script"

Set-ExecutionPolicy Unrestricted -Scope LocalMachine -Force

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# Remove HTTP listener
Remove-Item -Path WSMan:\Localhost\listener\listener* -Recurse

Set-Item WSMan:\localhost\MaxTimeoutms 1800000
Set-Item WSMan:\localhost\Service\Auth\Basic $true

$Cert = New-SelfSignedCertificate -CertstoreLocation Cert:\LocalMachine\My -DnsName "packer"
New-Item -Path WSMan:\LocalHost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $Cert.Thumbprint -Force

# WinRM
write-output "Setting up WinRM"
write-host "(host) setting up WinRM"

cmd.exe /c winrm quickconfig -q
cmd.exe /c winrm set "winrm/config" '@{MaxTimeoutms="1800000"}'
cmd.exe /c winrm set "winrm/config/winrs" '@{MaxMemoryPerShellMB="1024"}'
cmd.exe /c winrm set "winrm/config/service" '@{AllowUnencrypted="false"}'
cmd.exe /c winrm set "winrm/config/client" '@{AllowUnencrypted="false"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/client/auth" '@{Basic="true"}'
cmd.exe /c winrm set "winrm/config/service/auth" '@{CredSSP="true"}'
cmd.exe /c winrm set "winrm/config/listener?Address=*+Transport=HTTPS" "@{Port=`"5986`";Hostname=`"packer`";CertificateThumbprint=`"$($Cert.Thumbprint)`"}"
cmd.exe /c net stop winrm
cmd.exe /c sc config winrm start= auto
cmd.exe /c net start winrm

write-output "Allowing WinRM in Host Firewall"
write-host "(host) Allowing WinRM in Host Firewall"
New-NetFirewallRule -Protocol TCP -LocalPort 5986 -Direction Inbound -Action Allow -DisplayName WinRM

# Ref https://blog.alexellis.io/3-steps-to-msbuild-with-docker/
# for tools likely needed during build.

# From https://www.microsoft.com/en-us/download/details.aspx?id=48159
$msbuilddownload = "https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe"
Invoke-WebRequest $msbuilddownload -OutFile "$env:TEMP\BuildTools_Full.exe" -UseBasicParsing
& "$env:TEMP\BuildTools_Full.exe" /Silent /Full

$msbuilddir = (Get-ItemProperty hklm:\software\Microsoft\MSBuild\ToolsVersions\4.0).MSBuildToolsPath
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$msbuilddir;$oldpath"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

</powershell>
