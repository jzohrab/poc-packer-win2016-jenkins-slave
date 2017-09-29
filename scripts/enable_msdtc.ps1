# Script stolen from
# https://github.com/KlickInc/sensei-devops/,
# klick_shared_utils/recipes/msdtc.rb

Write-Output "Enable MSDTC"
$System_OS=(Get-WmiObject -class Win32_OperatingSystem).Caption
If ($System_OS -match "2012 R2") {
    Set-DtcNetworkSetting -DtcName Local -AuthenticationLevel Incoming -InboundTransactionsEnabled 1 -OutboundTransactionsEnabled 1 -RemoteClientAccessEnabled 1 -confirm:$false
}

Write-Output "Enable MSDTC Ports"
$path = "HKLM:\\Software\\Microsoft\\Rpc\\Internet"
IF(!(Test-Path -Path $path)) {
    New-Item -Path $path -Force | Out-Null
}
New-ItemProperty -Path $path -Name "Ports" -Value "5001-5100" -PropertyType MultiString -Force > $null
New-ItemProperty -Path $path -Name "UseInternetPorts" -Value "Y" -PropertyType String -Force > $null
New-ItemProperty -Path $path -Name "PortsInternetAvailable" -Value "Y" -PropertyType String -Force > $null
#   Configure Transaction Manager Communication
$msdtcpath = "HKLM:\\Software\\Microsoft\\MSDTC"
IF(!(Test-Path -Path $msdtcpath)) {
    New-Item -Path $msdtcpath -Force | Out-Null
}
New-ItemProperty -Path $msdtcpath -Name "AllowOnlySecureRpcCalls" -Value "0" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "FallbackToUnsecureRPCIfNecessary" -Value "0" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "TurnOffRpcSecurity" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "ServerTcpPort" -Value "5000" -PropertyType DWord -Force > $null

Write-Output "Enable MSDTC with proper settings"
$msdtcpath = "HKLM:\\Software\\Microsoft\\MSDTC\\Security"
IF(!(Test-Path -Path $msdtcpath)) {
    New-Item -Path $msdtcpath -Force | Out-Null
}
New-ItemProperty -Path $msdtcpath -Name "LuTransactions" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccess" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessAdmin" -Value "0" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessClients" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessInbound" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessOutbound" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessTip" -Value "0" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "NetworkDtcAccessTransactions" -Value "1" -PropertyType DWord -Force > $null
New-ItemProperty -Path $msdtcpath -Name "XaTransactions" -Value "1" -PropertyType DWord -Force > $null

Write-Output "Restart DTC Service"
Restart-Service MSDTC

Write-Output "Disable Windows Firewall"
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
