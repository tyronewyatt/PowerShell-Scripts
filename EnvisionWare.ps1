$envisionwarescript = @'
<!DOCTYPE Settings>
<Settings>
    <version>1</version>
    <type>PC Reservation Client</type>
    <entry name="Network: Management Service Auto-Discovery Port">0</entry>
    <entry name="Network: Management Service IP Address/Host Name">40.126.244.184</entry>
    <entry name="Network: Management Service Port">9432</entry>
    <collection name="Process Exceptions">
        <entry name="LPT:One Print Cost Management">Skip When Closing</entry>
    </collection>
</Settings>
'@

($envisionwarescript | Out-String) -replace "`n|`r`n", "`r`n" | Out-File "c:\ProgramData\EnvisionWare\PC Reservation\Client Module\config\pcrClient.ewp" -Encoding Ascii -NoNewline

$ACL = Get-Acl 'c:\ProgramData\EnvisionWare\PC Reservation\Client Module\config\pcrClient.ewp'
$SetOwner = New-Object System.Security.Principal.NTAccount 'BUILTIN\Administrators'
$ACL.SetOwner($SetOwner)
$SetGroup = New-Object System.Security.Principal.NTAccount 'AzureAD\LMUser'
$ACL.SetGroup($SetGroup)
$ACL | Set-Acl 'c:\ProgramData\EnvisionWare\PC Reservation\Client Module\config\pcrClient.ewp'