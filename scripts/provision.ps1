$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path "C:\provision.ps1.log" -append

# Install extra tools.
iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
choco install -y jre8 git

# Packages
# Ref http://www.systemcentercentral.com/automating-application-installation-using-powershell-without-dsc-oneget-2/

$source = 'C:\source'
If (!(Test-Path -Path $source -PathType Container)) {New-Item -Path $source -ItemType Directory | Out-Null} 

$packages = @(
    # (not using choco for MSBuild install as it doesn't set the path correctly)
    # From https://www.microsoft.com/en-us/download/details.aspx?id=48159
    @{
       title = 'MSBuild'
       url = 'https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe'
       Arguments = '/Silent /Full'
    }
#    @{title='7zip Extractor';url='http://downloads.sourceforge.net/sevenzip/7z920-x64.msi';Arguments=' /qn';Destination=$source},
#    @{title='Putty 0.63';url='http://the.earth.li/~sgtatham/putty/latest/x86/putty-0.63-installer.exe';Arguments=' /VERYSILENT /SUPPRESSMSGBOXES /NORESTART /SP-';Destination=$source}
#    @{title='Notepad++ 6.6.8';url='http://download.tuxfamily.org/notepadplus/6.6.8/npp.6.6.8.Installer.exe';Arguments=' /Q /S';Destination=$source} 
) 

# Download.
foreach ($package in $packages) {
    $packageName = $package.title
    $fileName = Split-Path $package.url -Leaf
    $destinationPath = $package.Destination + "\" + $fileName
    If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
        Write-Host "Downloading $packageName"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($package.url,$destinationPath)
    }
}

# Install
foreach ($package in $packages) {
    $packageName = $package.title
    $fileName = Split-Path $package.url -Leaf
    $destinationPath = $package.Destination + "\" + $fileName
    $Arguments = $package.Arguments
    Write-Output "Installing $packageName"
    Invoke-Expression -Command "$destinationPath $Arguments"
}

# Path updates
$msbuilddir = (Get-ItemProperty hklm:\software\Microsoft\MSBuild\ToolsVersions\4.0).MSBuildToolsPath
$oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$newpath = "$msbuilddir;$oldpath"
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

# Jenkins swarm
$swarm_url = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.4/swarm-client-3.4.jar"
Invoke-WebRequest $swarm_url -OutFile "C:/swarm-client.jar" -UseBasicParsing

Stop-Transcript
