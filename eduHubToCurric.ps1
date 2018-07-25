<#
.SYNOPSIS
  Name: eduHubToCurric.ps1
  Copy eduHub folder to curriclum server
  
.DESCRIPTION
  eduHub is a folder containing CSV data dumps from CASE21. 
  This script copies these CSV files from the admin network to a curriclum server. 
  The data is then used by other scripts and programs to import students into active directory ect.

.PARAMETER Password	
  password.txt contains the hashed curriclum password.
  
.NOTES
    Updated: 2018-07-23     Clean up code for multi school use.
    Release Date: 2018-02-21	Clean up code for second school use.
   
  Author: Tyrone Wyatt

.EXAMPLE
  Run in task scheduler:
  PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "D:\eduHubToCurric\eduHubToCurric.ps1"
#>

# Variables
$Source = 'D:\eduHub'
$Destination = '\\10.135.12.32\eduHub$'
$Username = "TALLANGATTA-SC\8370-eduHubAccess"
$Password = 'D:\eduHubToCurric\eduHubToCurricPassword.txt'
$Drive = 'X:'
$Date = Get-Date -UFormat "%Y-%m-%d"
$Log = "$Drive\$Date-RoboCopy.log"
$ToEMail = 'netbookadmin@tallangatta-sc.vic.edu.au'
$FromEMail = "8370AFS@tallangatta-sc.vic.edu.au"
$SmtpServer = 'mail.netspace.net.au'

# Create new password if password.txt is not found
If (!(Test-Path $Password)) {Read-host 'Enter Password' -AsSecureString | ConvertFrom-SecureString | Out-File $Password}

# Connect to destination server drive using curriclum username and password.txt hash
$PasswordSecureString = Get-Content $Password | ConvertTo-SecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $Username,$PasswordSecureString
New-PSDrive -Name $Drive.Substring(0,$Drive.Length-1) -Root $Destination -Persist -PSProvider FileSystem -Credential $Credential

# Copy eduHub$ folder to destination server
If (Test-Path $Drive)
    {Start-Process RoboCopy -ArgumentList "$Source $Drive /log+:$Log" -wait -NoNewWindow -PassThru}
Else
    {Send-MailMessage -To $ToEMail -From $FromEMail -Subject "eduHubtoCurric Failed" -SmtpServer $SmtpServer}

# Disconnect destination server drive
Remove-PSDrive -name $Drive.Substring(0,$Drive.Length-1) -Force