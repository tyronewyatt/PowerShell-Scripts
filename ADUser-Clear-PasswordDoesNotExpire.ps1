Import-Module ActiveDirectory

$OrganisationalUnit = 'OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True -And PasswordNeverExpires -eq $True} `
	-Properties samAccountName
	
ForEach ($User In $Users)
{
	$samAccountName = $User.'samAccountName'
	
	Set-ADUser `
		-Identity $samAccountName `
		-PasswordNeverExpires $False
	if($?)
		{
		Write-Host $samAccountName 'Password can expire.'
		}
}
