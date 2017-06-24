Import-Module ActiveDirectory

$OrganisationalUnit='OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$InitialPasswordAge='30'
$TemporaryPasswordAge='10'
$Users=Get-ADUser -SearchBase $OrganisationalUnit -Filter {Enabled -eq $True} -Properties samAccountName,pwdLastSet,lastLogonTimestamp,whenChanged,Description

ForEach ($User In $Users)
{
    $samAccountName = $User.'samAccountName'
	$pwdLastSet = $User.'pwdLastSet'
	$lastLogonTimestamp = $User.'lastLogonTimestamp'
	$whenChanged = $User.'whenChanged'
	$Description = $User.'Description'
	$InitialPasswordAge = $_.InitialPasswordAge
	$TemporaryPasswordAge = $_.TemporaryPasswordAge
	$DateString = (Get-Date).ToString()
	
If 	($Users | Where-Object `
		{ `
		$pwdLastSet -eq $False -And `
		$lastLogonTimestamp -eq $null -And `
		$whenChanged -lt (Get-Date).AddDays(-($InitialPasswordAge))
		}
	)
	{
	#Write-Host $samAccountName $Description - Initial password expired $DateString
	Disable-ADAccount -Identity $samAccountName
	if($?)
		{
		Set-ADUser -Identity $samAccountName -Description "$Description - Initial password expired $DateString"
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
	#Write-Host $samAccountName $Description - Temporary password expired $DateString
	Disable-ADAccount -Identity $samAccountName
	if($?)
		{
		Set-ADUser -Identity $samAccountName -Description "$Description - Temporary password expired $DateString"
		}
	}
}
