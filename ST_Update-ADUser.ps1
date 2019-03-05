<#
.SYNOPSIS
    Update student ADUser accounts based on ST table from CASES21
.DESCRIPTION
    Import data from CASES21 students table and update Active Directory student user accounts intomation and status.
.NOTES
    File Name      : ST_Update-ADUser.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt / Department of Education Victoria
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\ST_Update-ADUser.ps1 
.EXAMPLE
    .\ST_Update-ADUser.ps1 -Delta Yes 
 #>
Param(
	[String]$Delta = $(Read-Host 'Update users based on data differencing? Yes/NO')
	)

### Modules ###
Import-Module ActiveDirectory

### Script Variables ###
$SchoolID = '8843'
$eduHub = '\\cordc01\eduhub$'
$BaseDN = 'OU=Students,OU=Domain Users,DC=corryong,DC=vic,DC=edu,DC=au'
$RootDN = 'DC=corryong,DC=vic,DC=edu,DC=au'
$FQDN = 'corryong.vic.edu.au'
$Title = 'Student'
$Company = 'Corryong College'
$Manager0004 = 'CB' #Claudia BYRNE
$Manager0506 = 'SL' #Stephen LEARMONTH
$Manager07 = 'BK' #Brigitte KRSTIC
$Manager08 = 'SA' #Sarah AUSTIN
$Manager0910 = 'SS' #Susan SCOTT
$Manager1112 = 'BP' #Blaire PLOWMAN
$Office0004 = 'Junior Campus'
$Office0512 = 'Senior Campus'
$StreetAddress = '27-45 Towong Road'
$City = 'Corryong'
$State = 'Victoria'
$PostalCode = '3707'
$Country = 'AU'
$OfficePhone = '0260761566'

If ($Delta -Match 'Yes|True|1')
	{$CSVPath = $eduHub + '\ST_' + $SchoolID + '_D.csv'}
Else 
	{$CSVPath = $eduHub + '\ST_' + $SchoolID + '.csv'}

### Get AD Users ###
$ADUsers = Get-ADUser `
	-SearchBase $BaseDN `
	-Filter * `
	-Properties samAccountName,EmployeeNumber

### Import CSV Users ###
If (-Not ($CSVPath | Test-Path)) {Exit}
$CSVUsers = Import-Csv -Delimiter "," -Path $CSVPath
ForEach ($CSVUser In $CSVUsers)
    { 
    ### CSV Variables ###
	$Identity = $CSVUser.'STKEY'
	$Surname = $CSVUser.'SURNAME'
	$GivenName = $CSVUser.'FIRST_NAME'
	$Status = $CSVUser.'STATUS'
	$PrincipalName = $CSVUser.'STKEY' + '@' + $FQDN
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
	#DisplayName
	If ($CSVUser.'PREF_NAME' -Ne $Null -And $CSVUser.'PREF_NAME' -Ne $CSVUser.'FIRST_NAME')
		{$DisplayName = $CSVUser.'FIRST_NAME' + ' (' + $CSVUser.'PREF_NAME' + ') ' + $CSVUser.'SURNAME'}
	Else
		{$DisplayName = $CSVUser.'FIRST_NAME' + ' ' + $CSVUser.'SURNAME'}
    #Department
    If ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Department = $Null}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -Eq '00')
        {$Department = 'Preparatory'}
    Else
		{$Department = 'Year ' + $CSVUser.'SCHOOL_YEAR'}
	#Manager
	If ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Manager = $Null}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 00..04)
		{$Manager = $Manager0004}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 05..06)
		{$Manager = $Manager0506}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -Match '07')
		{$Manager = $Manager07}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -Match '08')
		{$Manager = $Manager08}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 09..10)
		{$Manager = $Manager0910}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 12..12)
		{$Manager = $Manager1112}
	Else 
		{$Manager = $Null}
	#Office
	If ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Office = $Null}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 00..04)
		{$Office = $Office0004}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -In 05..12)
		{$Office = $Office0512}
	Else
		{$Office = $Null}
    #Initials
    If ($CSVUser.'SECOND_NAME'.Length -Eq '0')
		{$Initials = $null}
	ElseIf ($CSVUser.'SECOND_NAME'.Length -Eq '1')
		{$Initials = $CSVUser.'SECOND_NAME'}
	Else
		{$Initials = $CSVUser.'SECOND_NAME'.SubString(0,1)}
    #EmployeeNumber
    If ($CSVUser.'VSN' -NotMatch 'NEW|UNKNOWN')
	    {$EmployeeNumber = $CSVUser.'VSN'}
    Else
        {$EmployeeNumber = $Null}
    #TimetableGroup
	If ($CSVUser.'STATUS' -Match 'FUT|DEL')
		{$TimetableGroup = ($CSVUser.'TAG').SubString(2)}
	ElseIf ($CSVUser.'STATUS' -Match 'LEFT')
		{$TimetableGroup = ($CSVUser.'TAG').SubString(1)}
	ElseIf ($CSVUser.'STATUS' -Eq $Null)
		{$TimetableGroup = $Null}
	Else
		{$TimetableGroup = $CSVUser.'TAG'}
	#AccountExpirationDate
	If ($CSVUser.'STATUS' -Match 'FUT')
		{$AccountExpirationDate = $Null}
	ElseIf ($CSVUser.'STATUS' -Match 'ACTV')
		{$AccountExpirationDate = $Null}
	ElseIf (($CSVUser.'STATUS' -Match 'LVNG') -And ($CSVUser.'DEPARTURE_DATE'.Length -Ne '0'))
		{$AccountExpirationDate = (Get-Date($CSVUser.'DEPARTURE_DATE')).AddDays(1)}
	ElseIf ($CSVUser.'STATUS' -Match 'LVNG')
		{$AccountExpirationDate = $Null}
	ElseIf (($CSVUser.'STATUS' -Match 'LEFT') -And ($CSVUser.'EXIT_DATE'.Length -Ne '0'))
		{$AccountExpirationDate = (Get-Date($CSVUser.'EXIT_DATE')).AddDays(1)}
	ElseIf (($CSVUser.'STATUS' -Match 'DEL') -And ($CSVUser.'DATELEFT'.Length -Ne '0'))
		{$AccountExpirationDate = (Get-Date($CSVUser.'DATELEFT')).AddDays(1)}
	Else
		{$AccountExpirationDate = (Get-Date).AddDays(-1)}

    ### If AD user found in CSV, set variables from CSV ###
	If (($ADUsers | Where-Object {$_.sAMAccountName -Eq $Identity}) -Ne $Null)
		{
		Set-ADUser `
			-Identity $Identity `
			-DisplayName $DisplayName `
			-GivenName $GivenName `
			-Surname $Surname `
			-Initials $Initials `
            -EmployeeNumber $EmployeeNumber `
			-Description $Description `
            -Title $Title `
            -Department $Department `
            -Company $Company `
            -Office $Office `
            -Manager $Manager `
            -StreetAddress $StreetAddress `
            -City $City `
            -State $State `
            -PostalCode $PostalCode `
            -Country $Country `
            -OfficePhone $OfficePhone `
            -PasswordNeverExpires $False `
			-AllowReversiblePasswordEncryption $False `
			-AccountExpirationDate $AccountExpirationDate `
            -PassThru
		}
}