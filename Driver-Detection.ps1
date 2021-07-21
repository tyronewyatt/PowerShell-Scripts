$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver
# Application detection state: Installed
If ($PnPSignedDriver.DeviceName -Eq "Realtek Audio" -And $PnPSignedDriver.DriverVersion -Eq "6.0.9107.1")
    {
    Write-Host $True
    Exit 0
    }
# Application detection state: Not installed
ElseIf ($PnPSignedDriver.DeviceName -Eq "Realtek Audio" -And $PnPSignedDriver.DriverVersion -Eq "6.0.8895.1")
    {Exit 0}
# Application detection state: Unknown
Else 
    {Exit 1}