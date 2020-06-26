#Set details
$CSVPath = '.\8370_pwd_reset_log_yr8_new.csv'
$MailSubject = 'eduPass Registration Email'
$SchoolCode = '8370'
$FQDN = 'tallangatta-sc.vic.edu.au'
$Date = (Get-Date).ToString("dd MMMM, yyyy")
$Expiry = (Get-Date -Day 26 -Month 06 -Year 2021).ToString("dd MMMM, yyyy")
$SmtpServer = 'mail.tallangatta-sc.vic.edu.au'
$MailBCC = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$MailSignature = `
"<p>ICT Helpdesk<br />
Tallangatta Secondary College<br />
145 Towong Street Tallangatta, 3700, VIC<br />
t: 02 6071 5000 | f: 02 6071 2445<br />
e: ict.helpdesk@tallangatta-sc.vic.edu.au<br />
w: www.tallangatta-sc.vic.edu.au</p>"

#Import data and generate email for each user
$Users = Import-Csv -Delimiter "," -Path $CSVPath
ForEach ($User In $Users)
	{
	$FirstName = $User.'First Name'
	$LastName = $User.'Last Name'
    $UserName = $User.'Login'.ToUpper()
    $Email = $User.'Login'.ToLower() + '@schools.vic.edu.au'
	$NewPassword = $User.'New Password'
	$HomeGroup = $User.'Home Group'
	$MailTo = "$User.'First Name' + ' ' + $User.'Last Name' ' <$STKEY@$FQDN>"

$MailBody = `
"<span style='font-family:Tahoma;'>
<h1>Department of Education and Training - Victoria</h1>

<h2 style='text-align:center;color:blue;'>$FirstName $LastName`: eduPass Registration Email</h2>

<p>$Date</p>

<p style='text-align:right'>Home Group: $HomeGroup<br />School Code: $SchoolCode</p>

<p><b>Dear $FirstName</b></p>

<p>Welcome to eduPass!</p>

<p>Your eduPass account provides you with secure access to Information and Technology resources provided by our school and the Department i.e. Minecraft, Adobe, Career e-Portfolio, Linked In and many more packages.</p>

<p><b>Your eduPass User Name and password are:</b></p>

    <p style='margin-left:50px;'><b>User Name:</b> $UserName</p>
    
    <p style='margin-left:50px;'><b>Email:</b> $Email</p>

    <p style='margin-left:50px;'><b>Password:</b> $NewPassword</p>

    <p style='margin-left:50px;'><b>Password Expiry Date:</b> $Expiry</p>

    <p style='margin-left:50px;'>Your password will expire in 365 days, on the date above.</p>

<div style='border-style:solid; border-width:1px; padding:10px; margin:10px;'>

<p style='color:blue;'><b>Actions Required:</b></p>

<p>You must change your password to complete your account activation. To do this:</p>

<p style='margin-left:50px;'>1. Open a browser and navigate to <b>https://eduPassMyAccount.education.vic.gov.au</b></p>

<p style='margin-left:50px;'>2. Login <b>using your password and eduPass user name exactly as shown above</b> and follow the prompts to change your password.</p>

<p style='margin-left:50px;'>For assistance please view the following link: <u><b>How to change your eduPass password</u></b></p>

</div>
        
<p style='color:blue;'><b>Things to Remember for Password Management</b></p>

    <p style='margin-left:60px;'>1. You cannot change your password more than once every 24 hours.</p>

    <p style='margin-left:60px;'>2. You are required to change your password once every year; this can be done by going to <b>https://eduPassMyAccount.education.vic.gov.au</b> and following the prompts.</p>

    <p style='margin-left:60px;'>3. You should complete the Self-Service Registration so that you can reset your password if you forget it. Go to <b>https://eduPassMyAccount.education.vic.gov.au</b> and follow the prompts to register your account for Self-Service Password Reset.</p>

    <p style='margin-left:60px;'>For assistance in registering for Self-Service Password Reset please view the following link: <b><u>How to register for Self-Service Password Reset</b></u></p>

<p>For further information or questions, please contact your Teacher or appropriate School eduPass Administrator.</p>

<br />

<p><b>Before using the system it is recommended to read some important privacy information in the following document: http://www.education.vic.gov.au/Pages/privacy.aspx</b></p>

<br />

$MailSignature

</span>"

Send-MailMessage `
	-To $MailTo `
    -Bcc $MailBCC `
	-From $MailFrom `
	-Subject $MailSubject `
	-SmtpServer $SmtpServer `
	-Body $MailBody -BodyAsHtml 
}