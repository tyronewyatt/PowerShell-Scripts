Import-Csv -Path C:\eduhub\ST_8843.csv | `
Where-Object {$_.STATUS -Match 'FUT|ACTV|LVNG'} |  `
Select-Object STKEY, FIRST_NAME, SURNAME, @{Name='E_MAIL';Expression={$_.STKEY.ToLower() + '@corryong.vic.edu.au'}}, GENDER, HOME_GROUP, SCHOOL_YEAR, @{Name='TITLE';Expression={'Student'}} | `
Export-Csv -NoTypeInformation -Path C:\SmartSuite\ST_8843.csv

Get-ADUser -Server 'corryong.vic.edu.au' -SearchScope Subtree -SearchBase 'OU=Staff,OU=Domain Users,DC=corryong,DC=vic,DC=edu,DC=au' -Filter '*' -Properties  mail | `
Select-Object @{Name='SFKEY';Expression={$_.SamAccountName.ToUpper()}}, @{Name='FIRST_NAME';Expression={$_.GivenName}}, @{Name='SURNAME';Expression={$_.Surname.ToUpper()}}, @{Name='E_MAIL';Expression={$_.mail.ToLower()}}, @{Name='TITLE';Expression={'Staff'}} | `
Export-csv -NoTypeInformation -Path C:\SmartSuite\SF_8843.csv

& 'C:\SmartSuite\WinSCP.exe' @('/command', 'open ftps://98:6819@ftp1.functionalsolutions.com.au', 'PUT C:\SmartSuite\S*_8843.csv') /log=C:\SmartSuite\FTPLog.txt /loglevel=-1