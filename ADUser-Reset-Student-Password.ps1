Import-Module ActiveDirectory   
Add-Type -AssemblyName System.web

$PasswordLength = '7'
$RunAsUser = $env:UserName.ToUpper()
$SmtpServer = 'mail.netspace.net.au'
$MailTo = 'Admin <tw@tallangattaps.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangattaps.vic.edu.au>'
$MailSignature = `
"ICT Helpdesk
Tallangatta Primary School
1 Wonga Grove Tallangatta, 3700, VIC
t: 02 6071 2590
e: ict.helpdesk@tallangattaps.vic.edu.au
w: www.tallangattaps.vic.edu.au"

$UserName = Read-Host -Prompt 'Enter Student Username'


$User = Get-ADUser `
	$UserName `
	-Properties samAccountName,displayName,enabled
If ($?)
	{
	$AccountName = $User.'samAccountName'.ToUpper()
	$FullName = $User.'displayName'
	$AccountStatus = $User.'enabled'
	}
	Else
	{
	Write-Host 'Press any key to exit'
	Read-Host
	Exit
	}

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
		Read-Host
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
		{$MailCC = 'No Reply <no-reply@tallangattaps.vic.edu.au>'}

	
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
	
Write-Host 'Press any key to exit'
Read-Host
Exit
