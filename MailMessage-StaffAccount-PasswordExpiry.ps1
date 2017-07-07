Import-Module ActiveDirectory

$MaximumPasswordAge = '126'
$WarningPasswordAge = '14'
$OrganisationalUnit = 'OU=Staff,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <tw@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True} `
	-Properties samAccountName,pwdLastSet,mail,givenName,displayName

ForEach ($User In $Users)
{
	$samAccountName = $User.'samAccountName'
	$Mail = $User.'mail'
	$FullName = $User.'displayName'
	$FirstName = $User.'givenName'
	#$MailTo = "'$FullName <$Mail>'"
	$pwdLastSet = [datetime]::fromFileTime($User.'pwdLastSet')
	$PasswordAgeDays = (New-TimeSpan -Start $pwdLastSet -End (Get-Date)).days
	$DaysToExipre = $MaximumPasswordAge-$PasswordAgeDays
	
If 	($Users | Where-Object `
		{ `
		$DaysToExipre -gt '0' -And `
		$DaysToExipre -le $WarningPasswordAge -And `
		$Mail -ne $Null
		}
	)
	{
	If ($DaysToExipre -ge '2')
		{
		Write-Host "$samAccountName password expires in $DaysToExipre days."
		$MailSubject = "Your password will expire in $DaysToExipre days"
		}
	ElseIf ($DaysToExipre -eq '1')
		{
		Write-Host "$samAccountName password expires tomorrow."
		$MailSubject = "Your password will expire tomorrow"
		}
		
$MailBody = `
"Hello $FirstName,

Your school Username ($samAccountName) and password give you access to the school's hosted systems (such as Computers, Outlook and LMS) and cloud hosted systems (such as Compass).

Your password will expire soon, please change your password now.

Passwords are valid for four months, so you must change your password at least three times a year.  This helps protect you and the Schools's network from possible breach of IT security. It is important that you keep your password private and not share it with anyone.

To change your password, logon to a school computer, press CTRL+ALT+DELETE and then click Change Password.

Important:

When you change your password, you must also update any other PC or device with your school Username and password stored on it.  Devices may include a notebook, iPad, other tablet, mobile phone and any other PC you use, including those at home.

Your new password must meet the following complexity requirements:
	1)	Not contain the username or parts of the user's full name that exceed two consecutive characters
	2)	Be at least seven characters in length
	3)	Contain characters from three of the following four categories:
		a)	English uppercase characters (A through Z)
		b)	English lowercase characters (a through z)
		c)	Base 10 digits (0 through 9)
		d)	Non-alphabetic characters (for example, !, $, #, %)
	4)	Unique new password not matching your past eight passwords

For further assistance:
	1)	Speak to the school ICT technician and school staff only.
	2)	Log a request on the school ICT Helpdesk, see: (https://helpdesk@tallangatta-sc.vic.edu.au).

ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}
}

