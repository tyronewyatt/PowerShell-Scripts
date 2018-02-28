# RunAs eduHub account to save password and run task scheduler!
# Uncomment line below for setting password and RunAs eduHub Account!

#Read-host 'Enter Password' -AsSecureString | ConvertFrom-SecureString | Out-File 'D:\UserCreator\Password.txt'

$SchoolNumber = '0123'
$CurriculumDomain = 'DOMAIN'
$Source = 'D:\eduHub'
$Destination = '\\10.xx.xx.x\eduHub$'
$UserName = "$CurriculumDomain\$SchoolNumber-eduHubAccess"
$Password = Get-Content 'D:\UserCreator\Password.txt' | ConvertTo-SecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $UserName,$Password
$Drive = 'X:'
$Date = Get-Date -UFormat "%Y-%m-%d"
$Log = "$Drive\$Date-RoboCopy.log"
$ToEMail = 'user@mail.com'
$FromEMail = 'no-reply@mail.com'
$SmtpServer = 'mail.netspace.net.au'

New-PSDrive -Name $Drive.Substring(0,$Drive.Length-1) -Root $Destination -Persist -PSProvider FileSystem -Credential $Credential

If (Test-Path $Drive)
    {Start-Process RoboCopy -ArgumentList "$Source $Drive /log+:$Log" -wait -NoNewWindow -PassThru}
Else
    {Send-MailMessage -To $ToEMail -From $FromEMail -Subject "eduHub@$SchoolNumberAFS01 Failed" -SmtpServer $SmtpServer}

Remove-PSDrive -name $Drive.Substring(0,$Drive.Length-1) -Force