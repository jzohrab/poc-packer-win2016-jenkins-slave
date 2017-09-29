# Set timezone.
tzutil /s 'Eastern Standard Time'

# Persist the timezone through system restarts.
# ref http://docs.aws.amazon.com/AWSEC2/latest/WindowsGuide/windows-set-time.html
$key = "HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\TimeZoneInformation"
reg add $key /v RealTimeIsUniversal /d 1 /t REG_DWORD /f