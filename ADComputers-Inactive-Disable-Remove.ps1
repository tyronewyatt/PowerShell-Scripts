Import-Module ActiveDirectory   

$DaysInactive = (Get-Date).AddDays(-1825) # 1825=5 years, 1095=3 years

# Get all AD computers with lastLogonTimestamp less than our time
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $DaysInactive} | FT Name,lastLogonDate

# If you would like to Disable these computer accounts, uncomment the following line:
#Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $DaysInactive} | Set-ADComputer -Enabled $false

# If you would like to Remove these computer accounts, uncomment the following line:
Get-ADComputer -Property Name,lastLogonDate -Filter {lastLogonDate -lt $DaysInactive} | Remove-ADComputer