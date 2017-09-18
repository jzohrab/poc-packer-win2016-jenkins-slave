$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

Start-Transcript -path "C:\provision.ps1.log" -append

# Amazon windows machine config is handled through ec2launch.
# http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/ec2launch.html

& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\InitializeInstance.ps1 -Schedule

# SysprepInstance shuts down the AMI.
$set_exec_policy_cmd = 'powershell -ExecutionPolicy Bypass -NoProfile -c "Set-ExecutionPolicy RemoteSigned -Scope LocalMachine -Force"'
Add-Content $Env:ProgramData\Amazon\EC2-Windows\Launch\Sysprep\SysprepSpecialize.cmd $set_exec_policy_cmd
& $Env:ProgramData\Amazon\EC2-Windows\Launch\Scripts\SysprepInstance.ps1

Stop-Transcript
