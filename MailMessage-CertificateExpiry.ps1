$Attachments = "$env:TEMP\CertificateExpiry.csv"
$WarningDays = '60'
$FilePath = '\\tallangatta-sc.vic.edu.au\Tools$\eduSTAR.net'
$SchoolID = '8370'
$Password = 'eduSTAR.NET'
$SmtpServer = 'mail.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$MailSignature = `
"ICT Helpdesk
Tallangatta Secondary College
145 Towong Street Tallangatta, 3700, VIC
t: 02 6071 5000 | f: 02 6071 2445
e: ict.helpdesk@tallangatta-sc.vic.edu.au
w: www.tallangatta-sc.vic.edu.au"

If($PSVersionTable.PSVersion.Major -le 5) {Throw "This script has not been tested with version 5 or older of PowerShell.  Please manually install PowerShell version 6, which will run side-by-side with your Windows supplied PowerShell."}

$Certs = Get-PfxCertificate -FilePath "$FilePath\$SchoolID-*.pfx" -Password $(ConvertTo-SecureString -String $Password -Force -AsPlainText) | Select-Object subject, NotAfter | Sort-Object NotAfter| Where-Object {$_.NotAfter -le $(Get-Date).AddDays($WarningDays)}

$Count = ($Certs.subject).Count

If ($Count -ge '1')
	{
	If ($Count -eq '1') 
		{
		$MailSubject = "Wireless certificate renewal required for 1 certificate"
		$MailHeading = "A wireless certificate is set to expire within $WarningDays days. See attached CSV file for more details."
		}
	Else
		{
		$MailSubject = "Wireless certificate renewal required for $Count certificates"
		$MailHeading = "$Count wireless certificates are set to expire within $WarningDays days. See attached CSV file for more details."
		}

$Certs | Export-Csv -Force -NoTypeInformation -Path $Attachments

$MailBody = `
"Hello Administrator,

$MailHeading

$MailSignature"	

Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -SmtpServer $SmtpServer -Body $MailBody -Attachments $Attachments

Remove-Item -Path $Attachments -Force
}