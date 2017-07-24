#Import modules
Import-Module ActiveDirectory   
Add-Type -AssemblyName System.web

# Script variables
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

# Get users from Active Directory
$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $False} `
	-Properties samAccountName,Description,displayName,DistinguishedName


ForEach ($User In $Users)
	{
	# Set ForEach variables 
	$AccountName = $User.'samAccountName'.ToUpper()
	$FullName = $User.'displayName'
	$Description = $User.'Description'
	$DistinguishedName = $User.'DistinguishedName'
	$TimetableGroup = $DistinguishedName.Substring(14,4)
	
	# Generate Password and ensure meets Active Directory complexity requirements
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
	
	# Check for expired user account passwords, reset passwords and user account description
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

	#Generate email if user account password reset occurred
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
