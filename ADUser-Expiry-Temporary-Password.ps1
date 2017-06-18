Import-Module ActiveDirectory

#Task to perform if account has expired. To enable a task remove # from start of line and to disable add # to start of line. Only uncomment one task.
$ExpiredPasswordTask="Disable-ADAccount" #Production
#$ExpiredPasswordTask="Write-Host" #Testing

#Limit AD SearchBase to OU
$AccountSearchBase="OU=Domain Users,DC=domain,DC=local"

#Number of days a new accounts password lasts before it expires
$InitialPasswordAge='30'

#Number of days an account temporary password lasts before it expires
$TemporaryPasswordAge='10'

# Search AD and perform task
Write-Host "Disable accounts after $InitialPasswordAge days if initial password not changed:"
Get-ADUser -SearchBase $AccountSearchBase -Filter {Enabled -eq $True} -Properties Name,pwdLastSet,lastLogonTimestamp,whenChanged | Where-Object {($_.pwdLastSet -eq "0") -AND ($_.lastLogonTimestamp -eq $null) -AND ($_.whenChanged -lt (Get-Date).AddDays(-($InitialPasswordAge)))} | & $ExpiredPasswordTask -Verbose
Write-Host "Disable accounts after $TemporaryPasswordAge days if temporary password not changed:"
Get-ADUser -SearchBase $AccountSearchBase -Filter {Enabled -eq $True} -Properties Name,pwdLastSet,lastLogonTimestamp,whenChanged | Where-Object {($_.pwdLastSet -eq "0") -AND ($_.lastLogonTimestamp -ne $null) -AND ($_.whenChanged -lt (Get-Date).AddDays(-($TemporaryPasswordAge)))} | & $ExpiredPasswordTask -Verbose
