Import-Module ActiveDirectory
Add-Type -AssemblyName System.web

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
		Else
		{If ($Student.'SECOND_NAME'.length -eq '1')
			{$SecondNameInitial = $Student.'SECOND_NAME'}
			Else
			{$SecondNameInitial = $Student.'SECOND_NAME'.Substring(0,1)}
		}
	$DisplayName = $Student.'FIRST_NAME' + " " + $Student.'SURNAME'
	If ($Student.'TAG' -match "\*\**")
		{$Student.'TAG' = ($Student.'TAG').substring(2)}
	$OrganisationalUnit = "OU=" + $Student.'TAG' + "," + $OrganisationalUnitBase
	$GroupMember = $Description + "s " + $Student.'TAG'
	$StartDate = $Student.'ENTRY'
	$Status = $Student.'STATUS'
	$PrincipalName = $AccountName + "@" + $DomainName
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	If (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -eq $Null)
		{
		New-ADUser `
			-Name "$AccountName" `
			-DisplayName "$DisplayName" `
			-SamAccountName $AccountName `
			-UserPrincipalName $PrincipalName `
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
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{
		$MailSubject = "Created 1 uaer account"
		$MailHeading = "The following user account has been created:"
		}
		Else
		{
		$MailSubject = "Created $NumberAccountsDisabled user accounts"
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
