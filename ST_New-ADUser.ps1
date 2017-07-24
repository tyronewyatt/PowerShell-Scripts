# Import modules
Import-Module ActiveDirectory
Add-Type -AssemblyName System.web

# Script variables
$SchoolNumber = '8370'
$OrganisationalUnitBase = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$DomainName = 'tallangatta-sc.vic.edu.au'
$Description = 'Student'
$PasswordLength = '7'
$CSVPath = '\\tscweb02\eduhub$'
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

# Get existing users from Active Directory
$ExistingStudents = Get-ADUser `
	-SearchBase $OrganisationalUnitBase `
	-Filter * `
	-Properties samAccountName

# Get future and active users from CSV
$Students = Import-Csv -Delimiter "," -Path "$CSVPath\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'FUT|ACTV'}
ForEach ($Student In $Students)
{
	# Set variables from CSV data
	$AccountName = $Student.'STKEY'
	$LastName = $Student.'SURNAME'
	$FirstName = $Student.'FIRST_NAME'
	$SecondName = $Student.'SECOND_NAME'
	$PreferredName = $Student.'PREF_NAME'
	If ($Student.'SECOND_NAME'.length -eq '0')
		{$SecondNameInitial = $null}
	ElseIF ($Student.'SECOND_NAME'.length -eq '1')
		{$SecondNameInitial = $Student.'SECOND_NAME'}
	Else
		{$SecondNameInitial = $Student.'SECOND_NAME'.Substring(0,1)}
	$DisplayName = $Student.'FIRST_NAME' + " " + $Student.'SURNAME'
	If ($Student.'TAG' -match "\*\**")
		{$TimetableGroup = ($Student.'TAG').substring(2)}
	Else
		{$TimetableGroup = $Student.'TAG'}
	$OrganisationalUnit = "OU=" + $TimetableGroup + "," + $OrganisationalUnitBase
	$GroupMember = $Description + "s " + $TimetableGroup
	$StartDate = $Student.'ENTRY'
	$Status = $Student.'STATUS'
	$PrincipalName = $AccountName + "@" + $DomainName

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
	Until	(
		$ComplexPassword -match '[A-Z]' -And `
		$ComplexPassword -match '[0-9]' -And `
		$ComplexPassword -notmatch "[$AccountNamePasswordArray]|[$FullNamePasswordArray]"
		)

	# Create new user account if not exists in Active Directory and then add user to group
	If (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -eq $Null)
		{
		New-ADUser `
			-Name "$AccountName" `
			-DisplayName "$DisplayName" `
			-SamAccountName "$AccountName" `
			-UserPrincipalName "$PrincipalName" `
			-GivenName "$FirstName" `
			-Surname "$LastName" `
			-Initials "$SecondNameInitial" `
			-Description "$Description" `
			-AccountPassword (ConvertTo-SecureString $ComplexPassword -AsPlainText -Force) `
			-Enabled $true `
			-Path "$OrganisationalUnit" `
			-ChangePasswordAtLogon $true `
			–PasswordNeverExpires $false `
			-AllowReversiblePasswordEncryption $false
		Add-ADGroupMember `
			-Identity "$GroupMember" `
			-Members "$AccountName"
			If ($?)
				{
				Write-Host "UserName: $AccountName FullName: $DisplayName Status: $Status GroupMember: $GroupMember Initial Password: $ComplexPassword"
				$MailBody += @("`nUserName: $AccountName FullName: $DisplayName Status: $Status GroupMember: $GroupMember Initial Password: $ComplexPassword")
				}
		}
}

#Generate email if user account creation occurred
If ($MailBody -ne $Null)
	{
	$NumberAccountsCreated = ($MailBody).count
	If ($NumberAccountsCreated -eq '1') 
		{
		$MailSubject = "Created 1 uaer account"
		$MailHeading = "The following user account has been created:"
		}
	Else 
		{
		$MailSubject = "Created $NumberAccountsCreated user accounts"
		$MailHeading = "The following user accounts have been created:"
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