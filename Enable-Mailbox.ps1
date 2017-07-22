Import-Module ActiveDirectory

$OrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$Database = 'TSC-Students'

$Users = Get-ADUser `
		-SearchBase $OrganisationalUnit `
		-Filter * `
		-Properties samAccountName,mail,DistinguishedName
	
ForEach ($User In $Users)
	{
	$AccountName = $User.'SamAccountName'
	$mail = $User.'mail'
	$DistinguishedName = $User.'DistinguishedName'

	if ($User | Where-Object `
		{
		$mail -eq $null	-And `
		$DistinguishedName -like "*OU=20[0-9][0-9],$OrganisationalUnit"
		}
		)
			{
			Enable-Mailbox -Identity $AccountName -Database $Database
			}
	}
