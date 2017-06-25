Import-Module ActiveDirectory

$SchoolNumber = '8370'
$OrganisationalUnitBase = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$DomainName = 'tallangatta-sc.vic.edu.au'
$Description = 'Student'
$PasswordLength = '7'

Function ComplexPassword
	{
	$UppercaseCharacters = (-join ('abcdefghijkmnopqrstuvwxyz'.ToCharArray() | Get-Random -Count 4))
	$LowercaseCharacters = (-join ('ABCEFGHJKLMNPQRSTUVWXYZ'.ToCharArray() | Get-Random -Count 4))
	$Base10Digits = (-join ('1234567890'.ToCharArray() | Get-Random -Count 2))
	$NonalphanumericCharacters = (-join ("~!@#$%^&*_-+=`|\(){}[]:;<>,.?/".ToCharArray() | Get-Random -Count 2))
	$ComplexityRequirements = $UppercaseCharacters + $LowercaseCharacters + $Base10Digits + $NonalphanumericCharacters
	$ComplexPassword = -join ($ComplexityRequirements.ToCharArray() | Get-Random -Count $PasswordLength)
	Write-Output $ComplexPassword
	}

$ExistingStudents = Get-ADUser `
	-SearchBase $OrganisationalUnitBase `
	-Filter * `
	-Properties samAccountName

$Students = Import-Csv -Delimiter "," -Path "C:\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'ACTV|LVNG'}
ForEach ($Student In $Students)
{
	$AccountName = $Student.'STKEY'
	$LastName = $Student.'SURNAME'
	$FirstName = $Student.'FIRST_NAME'
	$SecondName = $Student.'SECOND_NAME'
	$PreferredName = $Student.'PREF_NAME'
	If ($Student.'SECOND_NAME'.length -eq '0')
		{$SecondNameInitial = $null}
		else
		{If ($Student.'SECOND_NAME'.length -eq '1')
			{$SecondNameInitial = $Student.'SECOND_NAME'}
			else
			{$SecondNameInitial = $Student.'SECOND_NAME'.Substring(0,1)}
		}
	$DisplayName = $Student.'FIRST_NAME' + " " + $Student.'SURNAME'
	$OrganisationalUnit = "OU=" + $Student.'TAG' + "," + $OrganisationalUnitBase
	$GroupMember = $Description + "s " + $Student.'TAG'
	$StartDate = $Student.'ENTRY'
	$PrincipalName = $AccountName + "@" + $DomainName
	$ComplexPassword = ComplexPassword
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
			-Description "$Description - Start Date $StartDate" `
			-AccountPassword (ConvertTo-SecureString $ComplexPassword -AsPlainText -Force) `
			-Enabled $true `
			-Path "$OrganisationalUnit" `
			-ChangePasswordAtLogon $true `
			–PasswordNeverExpires $false `
			-AllowReversiblePasswordEncryption $false
		Add-ADGroupMember `
			-Identity "$GroupMember" `
			-Members "$AccountName"
		Write-Host 'UserName: '$AccountName 'FullName: '$DisplayName 'GroupMember: '$GroupMember 'Initial Password: '$ComplexPassword
		}
}