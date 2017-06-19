Import-Module ActiveDirectory   

$DaysInactive="(Get-Date).Adddays(-(1825))" # 1825=5 years, 1095=3 years
  
# Get all AD computers with lastLogonTimestamp less than our time and output hostname lastLogonTimestamp into CSV 
Get-ADComputer -Filter {LastLogonTimeStamp -lt $DaysInactive} -Properties LastLogonTimeStamp | select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} | export-csv .\Inactive-Computers.csv -notypeinformation
  

