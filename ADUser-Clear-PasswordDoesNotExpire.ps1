Import-Module ActiveDirectory

#Limit AD SearchBase to OU
$OrganisationalUnit="OU=Domain Users,DC=domain,DC=local"

# Search AD and perform task
Write-Host 'Clear password never expire flag from the following accounts:'
Get-ADUser -SearchBase $OrganisationalUnit -Filter {Enabled -eq $True -And PasswordNeverExpires -eq $True} -Properties samAccountName | ForEach {Set-ADUser -Verbose -Identity $_.samAccountName -PasswordNeverExpires $False}
