Import-Module ActiveDirectory

$WarningPasswordAge = '14' 
$OrganisationalUnit = 'OU=Staff,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$DomainPolicyMaxPasswordAge = ((Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge).Days
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
#$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$SupportURL = 'https://helpdesk@tallangatta-sc.vic.edu.au'
$PasswordPortalURL = 'https://sso.tallangatta-sc.vic.edu.au/adfs/portal/updatepassword'
$SchoolHostedSystems = 'Computers, Outlook and LMS'
$SchoolCloudSystems = 'Compass'
$MailSignature = `
"ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True -And PasswordNeverExpires -eq $False -And mail -like "*"} `
	-Properties samAccountName,pwdLastSet,msDS-UserPasswordExpiryTimeComputed,mail,givenName,displayName

ForEach ($User In $Users)
{
	$AccountName = $User.'samAccountName'.ToUpper()
	$FullName = $User.'displayName'
	$FirstName = $User.'givenName'
	$pwdLastSet = $User.'pwdLastSet'
	$UserPasswordExpiryTimeComputed = $User.'msDS-UserPasswordExpiryTimeComputed'
	$Mail = $User.'mail'
	$MailTo = "$FullName <$mail>"
	If ($UserPasswordExpiryTimeComputed -notmatch '9223372036854775807|0')
		{
		$UserPasswordExpiryTime = [datetime]::fromFileTime($UserPasswordExpiryTimeComputed)
		$DaysToExipre = (New-TimeSpan -Start (Get-Date) -End $UserPasswordExpiryTime).Days
		}
	ElseIf ($DomainPolicyMaxPasswordAge -ne '0')
		{
		$pwdLastSet = [datetime]::fromFileTime($pwdLastSet)
		$PasswordAgeDays = (New-TimeSpan -Start $pwdLastSet -End (Get-Date)).Days
		$DaysToExipre = $DomainPolicyMaxPasswordAge-$PasswordAgeDays
		}
	Else
		{
		$DaysToExipre = $Null
		}
	
	If 	($Users | Where-Object `
		{ `
		$DaysToExipre -ge '1' -And `
		$DaysToExipre -le $WarningPasswordAge
		}
		)
	{
	If ($DaysToExipre -eq '1')
		{
		Write-Host "$AccountName password expires tomorrow."
		$MailSubject = "Your password will expire tomorrow"
		}
	Else
		{
		Write-Host "$AccountName password expires in $DaysToExipre days."
		$MailSubject = "Your password will expire in $DaysToExipre days"
		}

If ($PasswordPortalURL)
    {$ChangePasswordInstructions = "To change your password, open a web browser and navigate to $PasswordPortalURL"}
Else
    {$ChangePasswordInstructions = 'To change your password, logon to a school computer, press CTRL+ALT+DELETE and then click Change Password.'}
		
$MailBody = `
"Hello $FirstName,

Your school username ($AccountName) and password gives you access to the schools hosted systems (such as $SchoolHostedSystems) and cloud hosted systems (such as $SchoolCloudSystems).

Your password will expire soon, please change your password now.

Passwords are valid for four months, so you must change your password at least three times a year. This helps protect you and the schools network from possible breach of IT security. It is important that you keep your password private and not share it with anyone.

$ChangePasswordInstructions

Important:

When you change your password, you must also update any other PC or device with your school username and password stored on it. Devices may include a notebook, iPad, other tablet, mobile phone and any other PC you use, including those at home.

Your new password must meet the following complexity requirements:
	1)	Unique password not matching your past eight passwords
	2)	Be at least seven characters in length
	3)	Contain characters from three of the following four categories:
		a)	English uppercase characters (A through Z)
		b)	English lowercase characters (a through z)
		c)	Base 10 digits (0 through 9)
		d)	Non-alphabetic characters (for example, !, $, #, %)
	4)	Not contain your username or parts of your full name that exceed two consecutive characters

For further assistance:
	1)	Speak to the school ICT technician and school staff only.
	2)	Log a request on the school ICT Helpdesk, see: ($SupportURL).

$MailSignature"

	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}
}
