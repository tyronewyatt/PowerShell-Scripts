Import-Module ActiveDirectory
Add-Type -AssemblyName System.web

$SchoolNumber = '8370'
$OrganisationalUnit = 'OU=2017,OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$DomainName = 'tallangatta-sc.vic.edu.au'
$NewDescription = 'Student'
$PasswordLength = '7'
$CSVPath = '\\tscweb02\eduhub$'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <tw@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$MailSignature = `
"ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

$ExistingStudents = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $False} `
	-Properties samAccountName,Description,displayName,DistinguishedName

$Students = Import-Csv -Delimiter "," -Path "$CSVPath\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'ACTV'}
ForEach ($Student In $Students)
{
	$AccountName = $Student.'STKEY'
	$samAccountName = $ExistingStudents.'samAccountName'
	$FullName = $ExistingStudents.'displayName'
	$Description = $ExistingStudents.'Description'
	$DistinguishedName = $ExistingStudents.'DistinguishedName'
	$TimetableGroup = $DistinguishedName.Substring(14,4)
	If (($ExistingStudents | Where-Object `
		{
		$sAMAccountName -eq $AccountName -And `
		$Description -match "Student - LVNG.|Student - LEFT.|Student - DEL." #-And `
		#$_.DistinguishedName -like "*OU=20[0-9][0-9],$OrganisationalUnit"
		}
		)-ne $Null)
		{
		$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
		write-host $AccountName
		#Set-ADAccountPassword `
		#	-Identity $AccountName `
		#	-Reset `
		#	-NewPassword (ConvertTo-SecureString -AsPlainText $ComplexPassword -Force)
		If ($?)
			{
		#		Set-AdUser `
		#			-Identity $AccountName `
		#			-Enabled $true `
		#			-ChangePasswordAtLogon $true `
		#			-Description "$NewDescription"
			Write-Host "TimetableGroup: $TimetableGroup AccountName: $AccountName FullName: $FullName Password: $ComplexPassword"
			$MailBody += @("`nTimetableGroup: $TimetableGroup AccountName: $AccountName FullName: $FullName Password: $ComplexPassword")
			}
		}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsEnabled = ($MailBody).count
	If ($NumberAccountsEnabled -eq '1') 
		{
		$MailSubject = "Enabled 1 uaer account"
		$MailHeading = "The following user account has been enabled:"
		}
	Else 
		{
		$MailSubject = "Enabled $NumberAccountsEnabled user accounts"
		$MailHeading = "The following user accounts have been enabled:"
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