Import-Module ActiveDirectory

$SchoolNumber = '8370'
$StudentsOrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$CSVPath = '\\tscweb02\eduhub$'
$Description = 'Student'
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
			Write-Host "$AccountName user account disabled as status chabged to $Status on $Date."
			$MailBody += @("`n$AccountName user account disabled as status chabged to $Status on $Date.")
			}
		}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{
		$MailSubject = "Disabled 1 user account"
		$MailHeading = "The following user account has been disabled:"
		}
		Else
		{
		$MailSubject = "Disabled $NumberAccountsDisabled user accounts"
		$MailHeading = "The following user accounts have been disabled:"
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