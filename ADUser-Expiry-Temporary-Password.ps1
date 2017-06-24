Import-Module ActiveDirectory

$InitialPasswordAge = '30'
$TemporaryPasswordAge = '10'
$OrganisationalUnit = 'OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$Users = Get-ADUser -SearchBase $OrganisationalUnit -Filter {Enabled -eq $True} -Properties samAccountName,pwdLastSet,lastLogonTimestamp,whenChanged,Description

ForEach ($User In $Users)
{
	$InitialPasswordAge='30'
	$TemporaryPasswordAge='10'
	$samAccountName = $User.'samAccountName'
	$pwdLastSet = $User.'pwdLastSet'
	$lastLogonTimestamp = $User.'lastLogonTimestamp'
	$whenChanged = $User.'whenChanged'
	$Description = $User.'Description'
	$DateString = (Get-Date).ToString()
	
If 	($Users | Where-Object `
		{ `
		$pwdLastSet -eq $False -And `
		$lastLogonTimestamp -eq $null -And `
		$whenChanged -lt (Get-Date).AddDays(-($InitialPasswordAge))
		}
	)
	{
	Disable-ADAccount -Identity $samAccountName
	if($?)
		{
		Set-ADUser -Identity $samAccountName -Description "$Description - Initial password expired $DateString"
		Write-Host $samAccountName 'Initial password expired.'
		}
	}
If 	($Users | Where-Object `
		{ `
		$pwdLastSet -eq $False -And `
		$lastLogonTimestamp -ne $null -And `
		$whenChanged -lt (Get-Date).AddDays(-($TemporaryPasswordAge))
		}
	)
	{
	Disable-ADAccount -Identity $samAccountName
	if($?)
		{
		Set-ADUser -Identity $samAccountName -Description "$Description - Temporary password expired $DateString"
		Write-Host $samAccountName 'Temporary password expired.'
		}
	}
}
