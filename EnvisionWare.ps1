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


$envisionwarescript | Out-File "c:\ProgramData\pcrClient.ewp" -Encoding Ascii
($envisionwarescript | Out-String) -replace "`n", "`r`n" | Out-File "c:\ProgramData\pcrClient.ewp" -Encoding Ascii -NoNewline