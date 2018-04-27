### Modules ###
Import-Module ActiveDirectory

### Script Variables ###
$SchoolID = '8843'
$CSVPath = '\\corweb02\eduhub$\ST_' + $SchoolID + '.csv'
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
$StreetAddress = '27-45 Towong Street'
$City = 'Corryong'
$State = 'Victoria'
$PostalCode = '3700'
$Country = 'Au'
$OfficePhone = '0260761566'

### Get AD Users ###
$ADUsers = Get-ADUser `
	-SearchBase $BaseDN `
	-Filter {Enabled -eq $True} `
	-Properties samAccountName,EmployeeNumber,Enabled

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
	$Description = "$Title $Status"
	#DisplayName
	If ($CSVUser.'PREF_NAME' -Ne $Null -And $CSVUser.'PREF_NAME' -Ne $CSVUser.'FIRST_NAME')
		{$DisplayName = $CSVUser.'FIRST_NAME' + ' (' + $CSVUser.'PREF_NAME' + ') ' + $CSVUser.'SURNAME'}
	Else
		{$DisplayName = $CSVUser.'FIRST_NAME' + ' ' + $CSVUser.'SURNAME'}
    #Department
    If ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Department = $Null}
	ElseIf ($CSVUser.'SCHOOL_YEAR' -Eq '00')
        {$Department = 'Year P'}
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
    If ($CSVUser.'SECOND_NAME'.length -Eq '0')
		{$Initials = $null}
	ElseIf ($CSVUser.'SECOND_NAME'.length -Eq '1')
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
    #Enabled
	If ($CSVUser.'STATUS' -Match 'FUT|ACTV|LVNG')
		{$Enabled = $True}
	ElseIf ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$Enabled = $False}
	#AccountExpirationDate
	If ($CSVUser.'STATUS' -Match 'FUT')
		{$AccountExpirationDate = $CSVUser.'ENTRY'}
	ElseIf ($CSVUser.'STATUS' -Match 'ACTV')
		{$AccountExpirationDate = $Null}
	ElseIf ($CSVUser.'STATUS' -Match 'LVNG' -And $CSVUser.'EXIT_DATE' -Ne $Null)
		{$AccountExpirationDate = $CSVUser.'EXIT_DATE'}
	ElseIf ($CSVUser.'STATUS' -Match 'LVNG')
		{$AccountExpirationDate = $Null}
	ElseIf ($CSVUser.'STATUS' -Match 'LEFT|DEL')
		{$AccountExpirationDate = $CSVUser.'DATELEFT'}
	Else 
		{$AccountExpirationDate = $Null}

    ### If AD user found in CSV, set variables from CSV ###
	If (($ADUsers | Where-Object {$_.sAMAccountName -Eq $Identity}) -Ne $Null)
		{
		Set-ADUser `
			-Identity $Identity `
			-DisplayName $DisplayName `
			-GivenName $GivenName `
			-Surname $Surname `
			-Initials $Initials `
			-Description $Description `
            -EmployeeNumber $EmployeeNumber `
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
            –PasswordNeverExpires $False `
			-AllowReversiblePasswordEncryption $False `
			-AccountExpirationDate $AccountExpirationDate `
            -PassThru
		}
}