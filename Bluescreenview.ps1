try {
    Invoke-WebRequest -Uri "https://www.nirsoft.net/utils/bluescreenview.zip" -OutFile "$($ENV:Temp)\bluescreeview.zip"
    Expand-Archive "$($ENV:Temp)\bluescreeview.zip" -DestinationPath "$($ENV:Temp)" -Force
    Start-Process -FilePath "$($ENV:Temp)\Bluescreenview.exe" -ArgumentList "/scomma `"$($ENV:Temp)\bluescreeview.csv`"" -Wait
 
}
catch {
    Write-Host "BSODView Command has Failed: $($_.Exception.Message)"
    exit 1
}
 
$BSODs = get-content "$($ENV:Temp)\bluescreeview.csv" | ConvertFrom-Csv -Delimiter ',' -Header Dumpfile, Timestamp, Reason, Errorcode, Parameter1, Parameter2, Parameter3, Parameter4, CausedByDriver | foreach-object { $_.Timestamp = [datetime]::Parse($_.timestamp, [System.Globalization.CultureInfo]::CurrentCulture); $_ }
Remove-item "$($ENV:Temp)\bluescreeview.csv" -Force
 
$BSODFilter = $BSODs | where-object { $_.Timestamp -gt ((get-date).addhours(-24)) }
 
if (!$BSODFilter) {
    write-host "Healthy - No BSODs found in the last 24 hours"
}
else {
    write-host "Unhealthy - BSOD found. Check Diagnostics"
    $BSODFilter
    exit 1
}