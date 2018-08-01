<#
.SYNOPSIS
    Add new ADUser student accounts based on ST table from CASES21
.DESCRIPTION
    Import data from CASES21 students table and create new Active Directory student user accounts.
.NOTES
    File Name      : ST_Update-ADUser.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt / Department of Education Victoria
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\ST_Add-ADUser.ps1 s 
 #>
Param(
	[String]$Delta = $(Read-Host 'Update users based on data differencing? Yes/NO')
	)

### Modules ###
Import-Module ActiveDirectory
Add-Type -AssemblyName System.web

### Script Variables ###
$SchoolID = '8843'
$eduHub = '\\cordc01\eduhub$'
$BaseDN = 'OU=Students,OU=Domain Users,DC=corryong,DC=vic,DC=edu,DC=au'
$RootDN = 'DC=corryong,DC=vic,DC=edu,DC=au'
$FQDN = 'corryong.vic.edu.au'
$AccountPasswordLength = '7'
$Title = 'Student'
$Company = 'Corryong College'
$Office = 'Corryong College'
$Manager = ' '
$StreetAddress = '27-45 Towong Street'
$City = 'Corryong'
$State = 'Victoria'
$PostalCode = '3700'
$Country = 'Au'
$OfficePhone = '0260761566'
$SmtpServer = 'cormx01.corryong.vic.edu.au'
$MailTo = 'DL ICT Staff <dl.ictstaff@corryong.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@corryong.vic.edu.au>'
$MailSignature = `
"ICT Helpdesk
Corryong College
27-45 Towong Road Corryong, 3707, VIC
t: 02 6076 1566 
e: ict.helpdesk@corryong.vic.edu.au
w: www.corryong.vic.edu.au"

If ($Delta -Match 'Yes|True|1')
	{$CSVPath = $eduHub + '\ST_' + $SchoolID + '_D.csv'}
Else 
	{$CSVPath = $eduHub + '\ST_' + $SchoolID + '.csv'}

### Get AD Users ###
$ADUsers = Get-ADUser `
	-SearchBase $BaseDN `
	-Filter * `
	-Properties samAccountName

### Import CSV Users ###
$CSVUsers = Import-Csv -Delimiter "," -Path $CSVPath | Where-Object {$_.STATUS -Match 'FUT|ACTV'}
ForEach ($CSVUser In $CSVUsers)
	{
	### CSV Variables ###
	$Identity = $CSVUser.'STKEY'
	$Surname = $CSVUser.'SURNAME'
	$GivenName = $CSVUser.'FIRST_NAME'
	$SecondName = $CSVUser.'SECOND_NAME'
	$PreferredName = $CSVUser.'PREF_NAME'
	$StartDate = $CSVUser.'ENTRY'
	$Status = $CSVUser.'STATUS'
	$UserPrincipalName = $Identity + '@' + $FQDN
	#Description
	If ($CSVUser.'STATUS' -Match 'FUT')
		{$Description = 'Future'}
	ElseIf ($CSVUser.'STATUS' -Match 'ACTV')
		{$Description = 'Active'}
	ElseIf ($CSVUser.'STATUS' -Match 'LVNG')
		{$Description = 'Leaving'}
	ElseIf ($CSVUser.'STATUS' -Match 'LEFT')
		{$Description = 'Left'}
	ElseIf ($CSVUser.'STATUS' -Match 'DEL')
		{$Description = 'Deleted'}
	Else 
		{$Description = $Null}
	#Department
    If ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Department = $Null}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -Eq '00')
        {$Department = 'Preparatory'}
    Else
		{$Department = 'Year ' + $CSVUser.'SCHOOL_YEAR'}
	#Initials
	If ($CSVUser.'SECOND_NAME'.Length -Eq '0')
		{$Initials = $Null}
	ElseIF ($CSVUser.'SECOND_NAME'.Length -Eq '1')
		{$Initials = $CSVUser.'SECOND_NAME'}
	Else
		{$Initials = $CSVUser.'SECOND_NAME'.Substring(0,1)}
	$DisplayName = $CSVUser.'FIRST_NAME' + ' ' + $CSVUser.'SURNAME'
	#TimetableGroup
	If ($CSVUser.'STATUS' -Match 'FUT')
		{$TimetableGroup = ($CSVUser.'TAG').SubString(2)}
	ElseIf ($CSVUser.'STATUS' -Eq $Null)
		{$TimetableGroup = $Null}
	Else
		{$TimetableGroup = $CSVUser.'TAG'}
	$Path = 'OU=' + $TimetableGroup + ',' + $BaseDN
	#GroupMember
	If ($TimetableGroup -Eq $Null)
		{$GroupMember = $Null}
	Else
		{$GroupMember = $Title + 's ' + $TimetableGroup}
	#EmployeeNumber
    If ($CSVUser.'VSN' -NotMatch 'NEW|UNKNOWN')
	    {$EmployeeNumber = $CSVUser.'VSN'}
    Else
        {$EmployeeNumber = $Null}
	#Date
	If ($CSVUser.'STATUS' -Match 'FUT|ACTV')
		{$StatusDate = $CSVUser.'ENTRY'}
	Else 
		{$StatusDate = $Null}
	#AccountPassword
	$AccountPassword = [System.Web.Security.Membership]::GeneratePassword($AccountPasswordLength,1)
	### If CSV user found in AD, Create New AD User ###
	If (($ADUsers | Where-Object {$_.sAMAccountName -eq $Identity}) -eq $Null)
		{
		New-ADUser `
			-Name $Identity `
			-DisplayName $DisplayName `
			-SamAccountName $Identity `
			-UserPrincipalName $UserPrincipalName `
			-GivenName $GivenName `
			-Surname $Surname `
			-Initials $Initials `
			-Description $Description `
            -EmployeeNumber $EmployeeNumber `
            -Title $Title `
            -Department $Department `
            -Company $Company `
            -Office $Office `
            -StreetAddress $StreetAddress `
            -City $City `
            -State $State `
            -PostalCode $PostalCode `
            -Country $Country `
            -OfficePhone $OfficePhone `
			-AccountPassword (ConvertTo-SecureString $AccountPassword -AsPlainText -Force) `
			-Enabled $True `
			-Path $Path `
			-ChangePasswordAtLogon $True `
			–PasswordNeverExpires $False `
			-AllowReversiblePasswordEncryption $False `
			-PassThru
		Add-ADGroupMember `
			-Identity $GroupMember `
			-Members $Identity `
			-PassThru
			If ($?)
				{
				$MailBody += @("`
UserName: $Identity `
FullName: $DisplayName `
Status: $Status `
GroupMember: $GroupMember `
Year Level: $Department `
Initial Password: $ComplexPassword `

				")
				}
		}
	}

If ($MailBody -ne $Null)
	{
	$NumberAccountsCreated = ($MailBody).count
	If ($NumberAccountsCreated -eq '1') 
		{
		$MailSubject = "Created 1 user account"
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