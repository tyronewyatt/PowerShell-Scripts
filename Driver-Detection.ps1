$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq "Realtek Audio"}
$ComputerSystem = Get-WmiObject Win32_ComputerSystem

If ($ComputerSystem.Manufacturer -Like 'Dell*' -And $ComputerSystem.Model -Match 'Latitude 7280|Latitude 7290|Latitude 7380|Latitude 7390|Latitude 7480|Latitude 7490')
    {
    # Application Installed
    If ($PnPSignedDriver.DriverVersion -Ge '6.0.9107.1')
        {
        Write-Host $True
        Exit 0
        }

    # Application Not installed
    ElseIf ($PnPSignedDriver.DriverVersion -Lt '6.0.9107.1')
        {Exit 0}
    }

# Application Unknown
Else 
    {Exit 1}
