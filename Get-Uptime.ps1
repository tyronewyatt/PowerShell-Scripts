$LastBootUpTime = (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
$Date = Get-Date
$Date - $LastBootUpTime |
Select @{name="Days";expression={$_.Days}}, 
    @{name="Hours";expression={$_.Hours}}, 
    @{name="Minutes";expression={$_.Minutes}}