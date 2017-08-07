Import-Module ActiveDirectory   
Add-Type -AssemblyName System.web

$PasswordLength = '7'
$RunAsUser = $env:UserName.ToUpper()
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailNoReply = 'No Reply <no-reply@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$SupportURL = 'https://helpdesk.tallangatta-sc.vic.edu.au'
$MailSignature = `
"ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

$UserName = Read-Host -Prompt 'Enter Username'

Try
	{
	$User = Get-ADUser `
		$UserName `
		-Properties samAccountName,givenName,mail,displayName,enabled
	} 
Catch
	{
	Write-Host "Username $UserName not found!"
	Write-Host 'Press any key to exit'
	[void][System.Console]::ReadKey($True)
	Exit
	}
	
$AccountName = $User.'samAccountName'.ToUpper()
$FirstName = $User.'givenName'
$FullName = $User.'displayName'
$AccountStatus = $User.'enabled'
$mail = $User.'mail'

$CheckUser = "Reset password for $FullName ($AccountName) [y/n]"
$ConfirmUser = Read-Host "$CheckUser"
While($ConfirmUser -ne "y")
{
    If ($ConfirmUser -eq 'n') {Exit}
    ConfirmUser = Read-Host "$CheckUser"
}

If ($AccountStatus -eq $False)
		{
		Write-Host "User account is disabled!"
		Write-Host 'Please enable account and try again or contact your Administrator'
		Write-Host 'Press any key to exit'
		[void][System.Console]::ReadKey($True)
		Exit
		}

$AccountNameLength = $AccountName.Length
Do { 
	$AccountNamePasswordDoCount++
	$AccountNamePasswordVariable = $AccountName.Substring($AccountNamePasswordDoCount-1,3)
	$AccountNamePasswordArray += ("$AccountNamePasswordVariable|")
	} while($AccountNamePasswordDoCount -ne $AccountNameLength-2) 
$FullNameLength = $FullName.Length
Do { 
	$FullNamePasswordDoCount++
	$FullNamePasswordVariable = $FullName.Substring($FullNamePasswordDoCount-1,3)
	$FullNamePasswordArray += ("$FullNamePasswordVariable|")
	} while($FullNamePasswordDoCount -ne $FullNameLength-2) 
Do 	{
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	}
Until (
	$ComplexPassword -match '[A-Z]' -And `
	$ComplexPassword -match '[0-9]' -And `
	$ComplexPassword -notmatch "[$AccountNamePasswordArray]|[$FullNamePasswordArray]"
	)

Set-ADAccountPassword `
	-Identity $AccountName `
	-Reset `
	-NewPassword (ConvertTo-SecureString -AsPlainText $ComplexPassword -Force)
If ($?)
	{
	Set-AdUser `
		-Identity $AccountName `
		-ChangePasswordAtLogon $true
	$ComplexPassword | Clip.exe
	Write-Host "Password: $ComplexPassword"
	Write-Host 'Password has been copied to clipboard'
	Write-Host 'Temporary passwords will expire in 10 days if not changed'
	$MailHeading = "AccountName: $AccountName FullName: $FullName Password: $ComplexPassword"
	$MailSubject = "Reset password for 1 user account"
	}

	
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

Write-Host 'Password Reset Successful!'	
Write-Host 'Press any key to exit'
[void][System.Console]::ReadKey($True)
Exit
