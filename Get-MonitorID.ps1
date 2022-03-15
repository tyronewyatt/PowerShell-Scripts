function Decode {
    If ($args[0] -is [System.Array]) {
    [System.Text.Encoding]::ASCII.GetString($args[0])
    }
    Else {
    "Not Found"
    }
}

$Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
    
 ForEach ($Monitor in $Monitors) {  
    $Out = New-Object psobject
    $Out | Add-Member NoteProperty 'Manufacturer' (Decode ($Monitor.ManufacturerName -notmatch 0))
    $Out | Add-Member NoteProperty 'Name' (Decode ($Monitor.UserFriendlyName -notmatch 0))
    $Out | Add-Member NoteProperty 'Serial' (Decode ($Monitor.SerialNumberID -notmatch 0))
    Write-Output $Out
 }