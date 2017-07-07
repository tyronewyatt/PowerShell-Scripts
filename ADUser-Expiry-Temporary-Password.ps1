Import-Module ActiveDirectory

$InitialPasswordAge = '30'
$TemporaryPasswordAge = '10'
$OrganisationalUnit = 'OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ADUser-Expiry-Temporary-Password <tscdc01@tallangatta-sc.vic.edu.au>'

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True -And PasswordNeverExpires -eq $False} `
	-Properties samAccountName,pwdLastSet,lastLogonTimestamp,whenChanged,Description

ForEach ($User In $Users)
{
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
	Disable-ADAccount `
		-Identity $samAccountName
	If ($?)
		{
		Set-ADUser `
			-Identity $samAccountName `
			-Description "$Description - Initial password expired $DateString"
		Write-Host "$samAccountName Initial password expired."
		$MailBody += @("`n$samAccountName Initial password expired.")
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
	Disable-ADAccount `
		-Identity $samAccountName
	If ($?)
		{
		Set-ADUser `
			-Identity $samAccountName `
			-Description "$Description - Temporary password expired $DateString"
		Write-Host "$samAccountName Temporary password expired."
		$MailBody += @("`n$samAccountName Temporary password expired.")
		}
	}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{$MailSubject = "Disabled $NumberAccountsDisabled Account"}
		Else
		{$MailSubject = "Disabled $NumberAccountsDisabled Accounts"}
	ForEach ($MailBody In $MailBodys)
		{
		$MailBody = $MailBody
		}
	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}
