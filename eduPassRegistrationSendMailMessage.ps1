#Set details
$CSVPath = '.\8370_pwd_reset_log_yr8_new.csv'
$SchoolCode = '8370'
$FQDN = 'tallangatta-sc.vic.edu.au'
$SmtpServer = 'mail.tallangatta-sc.vic.edu.au'
$MailBCC = 'Netbook Admin <netbookadmin@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ICT Helpdesk <ict.helpdesk@tallangatta-sc.vic.edu.au>'
$MailSubject = 'eduPass Registration Email'
$MailSignature = `
    "ICT Helpdesk<br />
    Tallangatta Secondary College<br />
    145 Towong Street Tallangatta, 3700, VIC<br />
    t: <a href='tel://+612607150000'>02 6071 5000</a><br />
    e: <a href='mailto://ict.helpdesk@tallangatta-sc.vic.edu.au'>ict.helpdesk@tallangatta-sc.vic.edu.au</a><br />
    w: <a href='https://www.tallangatta-sc.vic.edu.au'>www.tallangatta-sc.vic.edu.au</a>"
$Date = (Get-Date).ToString("dd MMMM, yyyy")
$PasswordExpiryDate = (Get-Date -Day 26 -Month 06 -Year 2021).ToString("dd MMMM, yyyy")

#Import data and generate email for each user
$Users = Import-Csv -Delimiter "," -Path $CSVPath
ForEach ($User In $Users)
    {
    $FirstName = $User.'First Name'
    $LastName = $User.'Last Name'
    $UserName = $User.'Login'.ToUpper()
    $Email = $User.'Login'.ToLower() + '@schools.vic.edu.au'
    $Password = $User.'New Password'
    $HomeGroup = $User.'Home Group'
    $STKEY = $User.'STKEY'
    $DisplayName = $User.'First Name' + ' ' + $User.'Last Name'
    $MailTo = "$DisplayName <$STKEY@$FQDN>"

$MailBody = `
"<span style='font-family:Tahoma;'>
    <h1>Department of Education and Training - Victoria</h1>
    <h2 style='text-align:center;color:blue;'>$FirstName $LastName`: $MailSubject</h2>
    <p>$Date</p>
    <p style='text-align:right'>Home Group: $HomeGroup<br />School Code: $SchoolCode</p>
    <p style='font-weight:bold'>Dear $FirstName</p>
    <p>Welcome to eduPass!</p>
    <p>Your eduPass account provides you with secure access to Information and Technology resources provided by our school and the Department, i.e. Minecraft, ClickView, Adobe, Career e-Portfolio, Linked In and many more packages.</p>
    <p style='font-weight:bold'>Your eduPass User Name and password are:</p>
    <p style='margin-left:50px;'><b>User Name:</b> $UserName</p>
    <p style='margin-left:50px;'><b>Email:</b> $Email</p>
    <p style='margin-left:50px;'><b>Password:</b> $Password</p>
    <p style='margin-left:50px;'><b>Password Expiry Date:</b> $PasswordExpiryDate</p>
    <p style='margin-left:50px;'>Your password will expire in 365 days, on the date above.</p>
    <div style='border-style:solid; border-width:1px; padding:10px; margin:10px;'>
        <p style='color:blue;font-weight:bold'>Actions Required:</p>
        <p>You must change your password to complete your account activation. To do this:</p>
        <p style='margin-left:50px;'>1. Open a browser and navigate to <a style='font-weight:bold' href='https://eduPassMyAccount.education.vic.gov.au'>https://eduPassMyAccount.education.vic.gov.au</a></p>
        <p style='margin-left:50px;'>2. Login <b>using your password and eduPass user name exactly as shown above</b> and follow the prompts to change your password.</p>
        <p style='margin-left:50px;'>For assistance please view the following link: <u><b>How to change your eduPass password</u></b></p>
    </div>
    <p style='color:blue;font-weight:bold'>Things to Remember for Password Management</p>
    <p style='margin-left:60px;'>1. You cannot change your password more than once every 24 hours.</p>
    <p style='margin-left:60px;'>2. You are required to change your password once every year; this can be done by going to <a style='font-weight:bold' href='https://eduPassMyAccount.education.vic.gov.au'>https://eduPassMyAccount.education.vic.gov.au</a> and following the prompts.</p>
    <p style='margin-left:60px;'>3. You should complete the Self-Service Registration so that you can reset your password if you forget it. Go to <a style='font-weight:bold' href='https://eduPassMyAccount.education.vic.gov.au'>https://eduPassMyAccount.education.vic.gov.au</a> and follow the prompts to register your account for Self-Service Password Reset.</p>
    <p style='margin-left:60px;'>For assistance in registering for Self-Service Password Reset please view the following link: <b><u>How to register for Self-Service Password Reset</b></u></p>
    <p>For further information or questions, please contact your Teacher or appropriate School eduPass Administrator.</p>
    <br />
    <p style='font-weight:bold'>Before using the system it is recommended to read some important privacy information in the following document: <a style='font-weight:bold' href='http://www.education.vic.gov.au/Pages/privacy.aspx'>http://www.education.vic.gov.au/Pages/privacy.aspx</a></p>
    <br />
    <p>
    $MailSignature
    </p>
</span>"

Send-MailMessage `
    -To $MailTo `
    -Bcc $MailBCC `
    -From $MailFrom `
    -Subject $MailSubject `
    -SmtpServer $SmtpServer `
    -Body $MailBody -BodyAsHtml 
}