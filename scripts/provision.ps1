$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path "C:\provision.ps1.log" -append

# Packages
# Ref http://www.systemcentercentral.com/automating-application-installation-using-powershell-without-dsc-oneget-2/

$downloadfolder = 'C:\installers'
If (!(Test-Path -Path $downloadfolder -PathType Container)) {New-Item -Path $downloadfolder -ItemType Directory | Out-Null} 

$packages = @(
    # (not using choco for MSBuild install as it doesn't set the path correctly)
    # From https://www.microsoft.com/en-us/download/details.aspx?id=48159
    @{
       filename = "BuildTools_Full.exe"
       url = 'https://download.microsoft.com/download/E/E/D/EEDF18A8-4AED-4CE0-BEBE-70A83094FC5A/BuildTools_Full.exe'
       args = '/Silent /Full'
    },

    @{
       filename = "rubyinstaller-2.3.1.exe"
       url = "http://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-2.3.1.exe"
       args = '/silent'
    },
    
    @{
       filename = "node-v6.10.2-x64.msi"
       url = "https://nodejs.org/dist/v6.10.2/node-v6.10.2-x64.msi"
    },

    @{
       filename = "SQLSysClrTypes.msi"
       url = "http://go.microsoft.com/fwlink/?LinkID=239644&clcid=0x409"
    },

    @{
       filename = "SQLSysClrTypesx86.msi"
       url = "https://download.microsoft.com/download/4/B/1/4B1E9B0E-A4F3-4715-B417-31C82302A70A/ENU/x86/SQLSysClrTypes.msi"
    },

    @{
       filename = "SharedManagementObjects.msi"
       url = "http://go.microsoft.com/fwlink/?LinkID=239659&clcid=0x409"
    },

    @{
       filename = "SharedManagementObjectsx86.msi"
       url = "https://download.microsoft.com/download/4/B/1/4B1E9B0E-A4F3-4715-B417-31C82302A70A/ENU/x86/SharedManagementObjects.msi"
    },

    @{
       filename = "PowerShellTools.msi"
       url = "http://go.microsoft.com/fwlink/?LinkID=239656&clcid=0x409"
    },

    @{
       filename = "PowerShellToolsx86.msi"
       url = "https://download.microsoft.com/download/4/B/1/4B1E9B0E-A4F3-4715-B417-31C82302A70A/ENU/x86/PowerShellTools.msi"
    }
) 

# Download.
foreach ($package in $packages) {
    $filename = $package.filename
    $destinationPath = $downloadfolder + "\" + $filename
    If (!(Test-Path -Path $destinationPath -PathType Leaf)) {
        Write-Host "Downloading $filename"
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($package.url,$destinationPath)
    }
}

# Install
foreach ($package in $packages) {
    $filename = $package.filename
    $args = $package.args
    $fullpath = "${downloadfolder}\${filename}"

    # for notes on piping to Out-Null, see
    # https://stackoverflow.com/questions/1741490/ \
    #   how-to-tell-powershell-to-wait-for-each-command-to-end-before-starting-the-next
    if ($filename.ToLower().EndsWith('msi')) {
        # Need to -wait for msi to install completely.
        # ref https://www.reddit.com/r/PowerShell/ \
        #   comments/34xobk/installing_msi_quietly/
        Write-Output "Installing $fullpath"
        Start-Process `
            -FilePath "$env:systemroot\system32\msiexec.exe" `
            -ArgumentList "/i $fullpath /qn /norestart" -Wait `
            -WorkingDirectory $downloadfolder
    }
    else {
       $command = "$fullpath $args | Out-Null"  # Default
       Write-Output "Installing $filename with command ""$command"""
       Invoke-Expression -Command $command
    }
}


# Setting path
# Ref https://stackoverflow.com/questions/714877/setting-windows-powershell-path-variable
function Add-EnvPath {
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,

        [ValidateSet('Machine', 'User', 'Session')]
        [string] $Container = 'Session'
    )

    if ($Container -ne 'Session') {
        $containerMapping = @{
            Machine = [EnvironmentVariableTarget]::Machine
            User = [EnvironmentVariableTarget]::User
        }
        $containerType = $containerMapping[$Container]

        $persistedPaths = [Environment]::GetEnvironmentVariable('Path', $containerType) -split ';'
        if ($persistedPaths -notcontains $Path) {
            $persistedPaths = $persistedPaths + $Path | where { $_ }
            [Environment]::SetEnvironmentVariable('Path', $persistedPaths -join ';', $containerType)
        }
    }

    $envPaths = $env:Path -split ';'
    if ($envPaths -notcontains $Path) {
        $envPaths = $envPaths + $Path | where { $_ }
        $env:Path = $envPaths -join ';'
    }
    Write-Output $env:Path
}

# Path updates
# Ref https://blogs.technet.microsoft.com/heyscriptingguy/2011/07/23/use-powershell-to-modify-your-environmental-path/
# $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
$msbuilddir = (Get-ItemProperty hklm:\software\Microsoft\MSBuild\ToolsVersions\4.0).MSBuildToolsPath

Add-EnvPath "C:\Ruby23\bin" "Machine"
Add-EnvPath $msbuilddir "Machine"

# $newpath = "C:\Ruby23\bin;$msbuilddir;$oldpath"
# Write-Output $newpath
# Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newpath

iex ((New-Object System.Net.WebClient).DownloadString("https://chocolatey.org/install.ps1"))
choco install -y jre8 git

# Jenkins swarm
$swarm_url = "https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/3.4/swarm-client-3.4.jar"
Invoke-WebRequest $swarm_url -OutFile "C:/swarm-client.jar" -UseBasicParsing

Stop-Transcript
