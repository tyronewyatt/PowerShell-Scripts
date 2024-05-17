
$Password = 'password'

$SearchBase = 'OU=Standard,OU=Users,OU=SCC,DC=shellharbour,DC=nsw,DC=gov,DC=au'

$ADUsers = Get-ADUser -SearchBase $SearchBase -Filter * -Properties Description, PasswordNeverExpires | 
    Where-Object {$_.Description -Like 'Pool Lifeguard*'}

Foreach ($ADUser in $ADUsers)
{$Username = $ADUser.'SamAccountName'

$TestPassword = (New-Object DirectoryServices.DirectoryEntry "LDAP://$SearchBase",$Username,$Password).psbase.name -ne $null
Write-Host $Username $TestPassword

}
