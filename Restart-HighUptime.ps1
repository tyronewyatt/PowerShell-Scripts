$HighUptime = 13 #Days
$Uptime = ((Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime).Days

$Computers = Get-VM -ComputerName tschv01, tschv02, tschv03 | Where-Object {$_.State -eq 'Running'}

If ($Computers.Uptime.Days -Gt $HighUptime)
    {Restart-Computer -ComputerName $Computers.Name -WsmanAuthentication Kerberos -Wait -For PowerShell -Timeout 300 -Delay 2}