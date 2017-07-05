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
$MailFrom = 'ST_Disable-ADUser <tscdc01@tallangatta-sc.vic.edu.au>'

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
	$OrganisationalUnit = "OU=" + $Student.'TAG' + "," + $OrganisationalUnitBase
	$GroupMember = $Description + "s " + $Student.'TAG'
	$StartDate = $Student.'ENTRY'
	$Status = $Student.'STATUS'
	$PrincipalName = $AccountName + "@" + $DomainName
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	if (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -eq $null)
		{
		New-ADUser `
			-Name "$AccountName" `
			-DisplayName "$DisplayName" `
			-SamAccountName $AccountName `
			-UserPrincipalName $PrincipalName `
			-GivenName "$FirstName" `
			-Surname "$LastName" `
			-Initials "$SecondNameInitial" `
			-Description "$Description - $Status $StartDate" `
			-AccountPassword (ConvertTo-SecureString $ComplexPassword -AsPlainText -Force) `
			-Enabled $true `
			-Path "$OrganisationalUnit" `
			-ChangePasswordAtLogon $true `
			–PasswordNeverExpires $false `
			-AllowReversiblePasswordEncryption $false `
		Add-ADGroupMember `
			-Identity "$GroupMember" `
			-Members "$AccountName" `
		Write-Host "UserName: $AccountName FullName: $DisplayName Status: $Status GroupMember: $GroupMember Initial Password: $ComplexPassword"
		$MailBody += @("`nUserName: $AccountName FullName: $DisplayName Status: $Status GroupMember: $GroupMember Initial Password: $ComplexPassword")
		}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{$MailSubject = "Created $NumberAccountsDisabled Account"}
		Else
		{$MailSubject = "Created $NumberAccountsDisabled Accounts"}
	ForEach ($MailBody In $MailBodys)
		{
		$MailBody = $MailBody
		}
	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}