Import-Module ActiveDirectory

$WarningPasswordAge = '30' 
$OrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
#$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$SupportURL = 'https://helpdesk.tallangatta-sc.vic.edu.au'
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
	-Filter {mail -like "dra0003@tallangatta-sc.vic.edu.au"} `
	-Properties samAccountName,accountExpires,mail,givenName,displayName

ForEach ($User In $Users)
{
	$AccountName = $User.'samAccountName'.ToUpper()
	$FullName = $User.'displayName'
	$FirstName = $User.'givenName'
	$accountExpiresTimeComputed = $User.'accountExpires'
	$Mail = $User.'mail'
	$MailTo = "$FullName <$mail>"
	If ($accountExpiresTimeComputed -notmatch '9223372036854775807')
		{
		$UserPasswordExpiryTime = [datetime]::fromFileTime($accountExpiresTimeComputed)
		$DaysToExipre = (New-TimeSpan -Start (Get-Date) -End $UserPasswordExpiryTime).Days
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
		Write-Host "$AccountName user account expires tomorrow."
		$MailSubject = "Your user account will expire tomorrow"
		}
	Else
		{
		Write-Host "$AccountName user account expires in $DaysToExipre days."
		$MailSubject = "Your user account will expire in $DaysToExipre days"
		}
		
$MailBody = `
"Hello $FirstName,

Your school username ($AccountName) and password gives you access to the schools hosted systems (such as $SchoolHostedSystems) and cloud hosted systems (such as $SchoolCloudSystems).

Your user account will expire soon, please visit the ICT department now.

Important:

Your user account will be deactivated when the expiry date is reached.

Please backup your data from your computer and emails before your user account expires.

School owned and managed computers must be returned to the ICT department before your last day at school.

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
