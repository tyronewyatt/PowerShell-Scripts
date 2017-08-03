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

$ExistingStudents = Get-ADUser `
	-SearchBase $OrganisationalUnitBase `
	-Filter * `
	-Properties samAccountName

$Students = Import-Csv -Delimiter "," -Path "$CSVPath\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'FUT|ACTV'}
ForEach ($Student In $Students)
{
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
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
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
