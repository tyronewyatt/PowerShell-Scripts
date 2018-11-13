#Cases21 School Code
$SchoolID = '8843'

#Destination Folder for the attendance file to be saved
$Destination = 'D:\eduHub\write-back'

#Fully Qualified Domain Name, needed for a valid web request
$FQDN = 'corryong.vic.edu.au'

#Curriculm web proxy, required as admin server can't resolve curriclum domains
$Proxy = 'http://10.136.236.19:8080'

#Curruculm authtication with SiMs_Staff access
$Username = 'CORRYONG\username'
$Password = 'D:\eduHubWriteBack\eduHubWriteBackPassword.txt'
If (!(Test-Path $Password)) {Read-host 'Enter Password' -AsSecureString | ConvertFrom-SecureString | Out-File $Password}
$PasswordSecureString = Get-Content $Password | ConvertTo-SecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $Username,$PasswordSecureString

#Url in SiMs format complete with start and end dates
$Url = [string]::Format("https://sims.{2}/Attendance/CSVExport?start={0}-01-01&end={1:yyyy-MM-dd}",(Get-Date).Year, (Get-Date), $FQDN) 

#Destination and file name including school ID in eduHub write-back format
$OutFile = [string]::Format("{0}\{1}_ATT-HALF-DAY.CSV",$Destination, $SchoolID)

#Invoke Web Request
Invoke-WebRequest -Uri $Url -OutFile $OutFile -Credential $Credential -Proxy $Proxy