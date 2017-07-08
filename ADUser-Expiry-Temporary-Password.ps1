Import-Module ActiveDirectory

$InitialPasswordAge = '30'
$TemporaryPasswordAge = '10'
$OrganisationalUnit = 'OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$MailSignature = `
"ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True -And PasswordNeverExpires -eq $False} `
	-Properties samAccountName,pwdLastSet,lastLogonTimestamp,whenChanged,Description

ForEach ($User In $Users)
{
	$AccountName = $User.'samAccountName'
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
		-Identity $AccountName
	If ($?)
		{
		Set-ADUser `
			-Identity $AccountName `
			-Description "$Description - Initial password expired $DateString"
		Write-Host "$AccountName initial password expired."
		$MailBody += @("`n$AccountName initial password expired.")
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
		-Identity $AccountName
	If ($?)
		{
		Set-ADUser `
			-Identity $AccountName `
			-Description "$Description - Temporary password expired $DateString"
		Write-Host "$AccountName temporary password expired."
		$MailBody += @("`n$AccountName temporary password expired.")
		}
	}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{
		$MailSubject = "Initial/temporary password expired for 1 user account"
		$MailHeading = "The following user account require your attention:"
		}
		Else
		{
		$MailSubject = "Initial/temporary password expired for $NumberAccountsDisabled user accounts"
		$MailHeading = "The following user accounts require your attention:"
		}
	ForEach ($MailBody In $MailBodys)
		{
		$MailBody = $MailBody
		}
		
$MailBody = `
"Hello Administrator,

$MailHeading
$MailBody

$MailSignature"	
		
	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}
