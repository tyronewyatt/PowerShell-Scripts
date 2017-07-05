Import-Module ActiveDirectory

$SchoolNumber = '8370'
$StudentsOrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$CSVPath = '\\tscweb02\eduhub$'
$Description = 'Student'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ST_Disable-ADUser <tscdc01@tallangatta-sc.vic.edu.au>'

$ExistingStudents = Get-ADUser `
	-SearchBase $StudentsOrganisationalUnit `
	-Filter {Enabled -eq $True} `
	-Properties samAccountName

$Students = Import-Csv -Delimiter "," -Path "$CSVPath\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'LVNG|LEFT|DEL'}
ForEach ($Student In $Students)
{
    $AccountName = $Student.'STKEY'
	$Status = $Student.'STATUS'
	$DateLeft = $Student.'DATELEFT'
	$DepartureDate = $Student.'DEPARTURE_DATE'
	$DestArrivalDate = $Student.'DEST_ARRIVAL_DATE'
	If ($DateLeft.length -ne '0') 
		{$Date = $DateLeft}
	ElseIf ($DepartureDate.length -ne '0')
		{$Date = $DepartureDate}
	ElseIf ($DestArrivalDate.length -ne '0')
		{$Date = $DestArrivalDate}
		
	If (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -ne $Null)
        {
		Disable-ADAccount `
			-Identity $AccountName
		If ($?)
			{
			Set-ADUser `
				-Identity $AccountName `
				-Description "$Description - $Status $Date"
			Write-Host "$AccountName Disabled. Description $Description - $Status $Date"
			$MailBody += @("`n$AccountName Disabled. Description $Description - $Status $Date")
			}
		}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{$MailSubject = "Disabled $NumberAccountsDisabled Account"}
		Else
		{$MailSubject = "Disabled $NumberAccountsDisabled Accounts"}
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