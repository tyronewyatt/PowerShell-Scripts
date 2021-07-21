$DriverVersion = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq "Realtek Audio"} | Select-Object -ExpandProperty DriverVersion 

# Application Installed
If ($DriverVersion -Ge "6.0.9107.1")
    {
    Write-Host $True
    Exit 0
    }

# Application Not installed
ElseIf ($DriverVersion -Lt "6.0.9107.1")
    {Exit 0}

# Application Unknown
Else 
    {Exit 1}