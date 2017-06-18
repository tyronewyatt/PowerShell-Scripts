Import-Module ActiveDirectory

#Limit AD SearchBase to OU
$AccountSearchBase="OU=Domain Users,DC=domain,DC=local"

# Search AD and perform task
Write-Host 'Clear password never expire flag from the following accounts:'
Get-ADUser -SearchBase $AccountSearchBase -Filter {Enabled -eq $True -AND PasswordNeverExpires -eq $True} -Properties Name,samAccountName | ForEach {Set-ADUser -Verbose -Identity $_.samAccountName -PasswordNeverExpires $False}