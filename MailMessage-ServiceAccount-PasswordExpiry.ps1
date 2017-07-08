Import-Module ActiveDirectory

$MaximumPasswordAge = '365'
$WarningPasswordAge = '30'
$OrganisationalUnit = 'OU=Services,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <tw@tallangatta-sc.vic.edu.au>'
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
	-Properties samAccountName,pwdLastSet,msDS-UserPasswordExpiryTimeComputed

ForEach ($User In $Users)
{
	$samAccountName = $User.'samAccountName'.ToUpper()
	$pwdLastSet = $User.'pwdLastSet'
	$UserPasswordExpiryTimeComputed = $User.'msDS-UserPasswordExpiryTimeComputed'
	
	If ($UserPasswordExpiryTimeComputed -ne $Null)
	{
	$UserPasswordExpiryTime = [datetime]::fromFileTime($UserPasswordExpiryTimeComputed)
	$DaysToExipre = (New-TimeSpan -Start (Get-Date) -End $UserPasswordExpiryTime).Days
	}
	Else
	{
	$pwdLastSet = [datetime]::fromFileTime($pwdLastSet)
	$PasswordAgeDays = (New-TimeSpan -Start $pwdLastSet -End (Get-Date)).Days
	$DaysToExipre = $MaximumPasswordAge-$PasswordAgeDays
	}
	
	$DaysExpired = $DaysToExipre.ToString().SubString(1)
	
If 	($Users | Where-Object `
		{ `
		$DaysToExipre -le $WarningPasswordAge
		}
	)
	{
	If ($DaysToExipre -ge '2')
		{
		Write-Host "$samAccountName password expires in $DaysToExipre days."
		$MailBody += @("`n$samAccountName password expires in $DaysToExipre days.")
		}
	ElseIf ($DaysToExipre -eq '1')
		{
		Write-Host "$samAccountName password expires tomorrow."
		$MailBody += @("`n$samAccountName password expires tomorrow.")
		}
	ElseIf ($DaysToExipre -eq '0')
		{
		Write-Host "$samAccountName password expired today."
		$MailBody += @("`n$samAccountName password expired today.")
		}
	ElseIf ($DaysToExipre -eq '-1')
		{
		Write-Host "$samAccountName password expired yesterday."
		$MailBody += @("`n$samAccountName password expired yesterday.")
		}
	ElseIf ($DaysToExipre -le '-2')
		{
		Write-Host "$samAccountName password expired $DaysExpired days ago."
		$MailBody += @("`n$samAccountName password expired $DaysExpired days ago.")
		}
	}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{$MailSubject = "Password change required for 1 service account"}
		Else
		{$MailSubject = "Password change required for $NumberAccountsDisabled service accounts"}
	ForEach ($MailBody In $MailBodys)
		{
		$MailBody = $MailBody
		}
		
$MailBody = `
"Hello Administrator,

The following service accounts require your attention:
$MailBody

$MailSignature"	
		
	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}