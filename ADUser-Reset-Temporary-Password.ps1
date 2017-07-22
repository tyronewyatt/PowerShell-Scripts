Import-Module ActiveDirectory   
Add-Type -AssemblyName System.web

$PasswordLength = '7'
$NewDescription = 'Student'
$OrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
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
	-Filter {Enabled -eq $False} `
	-Properties samAccountName,Description,displayName,DistinguishedName

	
ForEach ($User In $Users)
	{
	$AccountName = $User.'samAccountName'.ToUpper()
	$FullName = $User.'displayName'
	$Description = $User.'Description'
	$DistinguishedName = $User.'DistinguishedName'
	$TimetableGroup = $DistinguishedName.Substring(14,4)
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	If 	($Users | Where-Object `
		{
		$Description -match '.Initial password expired.|.Temporary password expired.' -And `
		$DistinguishedName -like "*OU=20[0-9][0-9],$OrganisationalUnit"
		}
		)
		{
		Set-ADAccountPassword `
			-Identity $AccountName `
			-Reset `
			-NewPassword (ConvertTo-SecureString -AsPlainText $ComplexPassword -Force)
		If ($?)
			{
			Set-AdUser `
				-Identity $AccountName `
				-Enabled $true `
				-ChangePasswordAtLogon $true `
				-Description "$NewDescription"
			Write-Host "TimetableGroup: $TimetableGroup AccountName: $AccountName FullName: $FullName Password: $ComplexPassword"
			$MailBody += @("`nTimetableGroup: $TimetableGroup AccountName: $AccountName FullName: $FullName Password: $ComplexPassword")
			}
		}
	}

	If ($MailBody -ne $Null)
		{
		$NumberAccountPasswordsReset = ($MailBody).count
		If ($NumberAccountPasswordsReset -eq '1') 
			{
			$MailSubject = "Reset password for 1 user account"
			$MailHeading = "The following user account password was reset:"
			}
		Else
			{
			$MailSubject = "Reset passwords for $NumberAccountPasswordsReset user accounts"
			$MailHeading = "The following user accounts passwords was reset:"
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