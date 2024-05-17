# Set Base Domain OU Name
$BaseOU = 'OU=Windows 10,OU=Computers,OU=SCC,DC=shellharbour,DC=nsw,DC=gov,DC=au'

# Get Wmi Objects
$ChassisType = (Get-WmiObject -Class Win32_SystemEnclosure).ChassisTypes
$Battery = Get-WmiObject -Class Win32_Battery

# Set Chassis Name from Chassis Type
If ($ChassisType -Eq '3' -Or ` # Desktop
    $ChassisType -Eq '4') # Low Profile Desktop
    {$ChassisName = 'Desktops'}

ElseIf ($ChassisType -Eq '9' -Or ` # Laptop
    $ChassisType -Eq '10' -Or ` # Notebook
    $ChassisType -Eq '14' -Or ` # Sub Notebook
    $ChassisType -Eq '18' -Or ` # Expansion Chassis
    $ChassisType -Eq '31' -Or ` # Convertible
    $Battery -Ne $Null) 
    {$ChassisName = 'Laptops'}

ElseIf ($ChassisType -Eq '13') # All in One
    {$ChassisName = 'All-in-Ones'}

Else
    {$ChassisName = 'Others'}

# Formulate Domain OU Name
$OSDDomainOUName = 'LDAP://OU=' + $ChassisName + ',' + $BaseOU

# Output Domain OU Name 
Write-Output $OSDDomainOUName