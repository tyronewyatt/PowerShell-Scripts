Param(
	[String]$UserName = $(Read-Host -Prompt 'Enter Username')
	)

# Import module
Add-Type -AssemblyName System.web

# Set variables
$RunAsUser = $env:UserName.ToUpper()
Function Pause {[void][System.Console]::ReadKey($True)}
$SmtpServer = 'cormx01.corryong.vic.edu.au'
$MailTo = 'DL ICT Staff <dl.ictstaff@corryong.vic.edu.au>'
$MailNoReply = 'No Reply <no-reply@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@corryong.vic.edu.au>'
$SupportURL = 'https://helpdesk.corryong.vic.edu.au'
$MailSignature = `
"ICT Helpdesk
Corryong College
27-45 Towong Road Corryong, 3707, VIC
t: 02 6076 1566 
e: ict.helpdesk@corryong.vic.edu.au
w: www.corryong.vic.edu.au"

#Check if domain admin
If(-Not((Get-ADPrincipalGroupMembership $env:USERNAME).name -Match "Domain Admins|Account Password Reset Operators"))
{
    Write-Warning "Not a Domain Admin! Goodbye"
    Break
}

# Get users details from AD if exists else exit
$User = Get-ADUser `
	$UserName `
	-Properties `
		samAccountName, `
		givenName, `
		mail, `
		displayName, `
		Description, `
		DistinguishedName, `
		enabled
If ($?)
	{
	$AccountName = $User.'samAccountName'.ToUpper()
	$FirstName = $User.'givenName'
	$FullName = $User.'displayName'
	$AccountStatus = $User.'enabled'
	$Description = $User.'Description'
	$DistinguishedName = $User.'DistinguishedName'
	$mail = $User.'mail'
	}
Else
	{
	Write-Host 'Press any key to exit'
	Pause
	Exit
	}

# Get users password length else use default domain policy
$UserPasswordPolicy = Get-ADUserResultantPasswordPolicy `
	$UserName
If ($?)
	{
	If ($UserPasswordPolicy.'MinPasswordLength' -ne $Null)
		{$DomainPolicyPasswordLength = $UserPasswordPolicy.'MinPasswordLength'}
	}
Else {
	$DomainPolicyPasswordLength = (Get-ADDefaultDomainPasswordPolicy).MinPasswordLength
	}

# Confirm user is correct before proceeding
$CheckUser = "Reset password for $FullName ($AccountName) [y/n]"
$ConfirmUser = Read-Host "$CheckUser"
While($ConfirmUser -Ne "y")
{
    If ($ConfirmUser -Match 'n|') {Exit}
    ConfirmUser = Read-Host "$CheckUser"
}

# Check if user account is enabled else exit
If ($AccountStatus -eq $False)
		{
		Write-Host 'User account is disabled!'
		Write-Host 'Press any key to continue'
		Pause
		}

# Set Description
Write-Host "UserAccount Description: $Description"
If ($DistinguishedName -Match 'OU=Student') {$Description = 'Student'}
If ($DistinguishedName -Match 'OU=Staff') {$Description = 'Staff'}
If ($DistinguishedName -Match 'OU=Administration') {$Description = 'Administration'}
If ($DistinguishedName -Match 'OU=Service') {$Description = 'Services'}	

# Ensure password meets domain complexity requirements
Function NameCompliance {
$NameCompliance1 = $Args[0]
Do { 
	$NameCompliance0++
	$NameCompliance2 = $NameCompliance1.Substring($NameCompliance0-1,3)
	$NameCompliance3 += ("$NameCompliance2|")
	} 
While ($NameCompliance0 -ne $NameCompliance1.Length-2) 
Write-Output $NameCompliance3
}
$NameCompliance = $(NameCompliance $AccountName) + $(NameCompliance $FullName).Substring(0,$(NameCompliance $FullName).Length-1)

# Generate password until compliance met
Do {
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($DomainPolicyPasswordLength,1)
	}
Until (
	$ComplexPassword -CMatch '[A-Z]' -And ` 
	$ComplexPassword -CMatch '[a-z]' -And ` 
	$ComplexPassword -Match '[0-9]' -And ` 
	$ComplexPassword -CNotMatch '[0|O|I|1|1]' -And ` 
	$ComplexPassword -NotMatch $NameCompliance 
	)

# Set new password and display on screen
Set-ADAccountPassword `
	-Identity $AccountName `
	-Reset `
	-NewPassword (ConvertTo-SecureString -AsPlainText $ComplexPassword -Force)
If ($?)
	{
	Set-AdUser `
		-Identity $AccountName `
		-ChangePasswordAtLogon $true `
		-Description $Description `
		-Enabled $true
	$ComplexPassword | Clip.exe
	Write-Host "Password:	$ComplexPassword"
	Write-Host 'Password has been copied to clipboard'
	$MailHeading = `
"AccountName:	$AccountName
FullName:	$FullName
Password:	$ComplexPassword"
	$MailSubject = "Reset password for 1 user account"
	}

# Email technicians copy of password
$User = Get-ADUser `
	$RunAsUser `
	-Properties Mail,displayName
$RunAsUserMail = $User.'Mail'
$RunAsUserFullName = $User.'displayName'
If ($RunAsUserMail -ne $Null)
		{$MailCC = "$RunAsUserFullName <$RunAsUserMail>"}
		Else
		{$MailCC = "$MailNoReply"}
	
$MailBody = `
"Hello Administrator,

$MailHeading
$MailBody
Reset by $RunAsUser.

$MailSignature"	
		
Send-MailMessage `
	-To "$MailTo" `
	-Cc "$MailCC" `
	-From "$MailFrom" `
	-Subject "$MailSubject" `
	-SmtpServer "$SmtpServer" `
	-Body "$MailBody"

# Email user copy of password
If ($mail -ne $Null)
		{$MailTo = "$FullName <$mail>"}
		Else
		{$MailTo = "$MailNoReply"}
$MailSubject = "Your password has been reset"

$MailBody = `	
"Hello $FirstName,
 	 
Your school password has been reset. Please note your temporary school password below:
 	 
School Password: $ComplexPassword
 	 
For security purposes, you must change your password. To change your password, logon to a school computer and follow the prompts.

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
	
Write-Host 'Press any key to exit'
Pause
Exit
