$Manufacturer = 'Dell'
$Model = 'Latitude 7490'
$DeviceName = 'Realtek Audio'
$DriverVersion = '6.0.9107.1'

$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq $DeviceName}
$ComputerSystem = Get-WmiObject Win32_ComputerSystem

If ($ComputerSystem.Manufacturer -Like "$Manufacturer*" -And $ComputerSystem.Model -Eq $Model)
    {
    # Application Installed
    If ($PnPSignedDriver.DriverVersion -Ge $DriverVersion)
        {
        Write-Host $True
        Exit 0
        }

    # Application Not installed
    ElseIf ($PnPSignedDriver.DriverVersion -Lt $DriverVersion)
        {Exit 0}
    }

# Application Unknown
Else 
    {Exit 1}
