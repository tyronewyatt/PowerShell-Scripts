Start-Transcript "$($env:windir)\temp\Realtek-High-Definition-Audio-Driver_88MRG_WIN_6.0.9107.1_A26.log"

$Manufacturer = 'Dell'
$Model = 'Latitude 7490'
$DeviceName = 'Realtek Audio'
$DriverVersion = '6.0.9107.1'

$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq $DeviceName}
$ComputerSystem = Get-WmiObject Win32_ComputerSystem

If ($ComputerSystem.Manufacturer -Like "$Manufacturer*" -And $ComputerSystem.Model -Eq $Model)
    {
    # Application Install
    If ($PnPSignedDriver.DriverVersion -Lt $DriverVersion) 
        {
        Get-ChildItem ".\" -Recurse -Filter "*.inf" | ForEach-Object {& PNPUtil.exe /install /add-driver $_.FullName}
        Stop-Transcript
        Exit 3010
        }

    # Application Installed
    ElseIf ($PnPSignedDriver.DriverVersion -Ge $DriverVersion) 
        {
        Write-Host $True
        Stop-Transcript
        Exit 0
        }
    }

# Application Error
Else 
    {
    Stop-Transcript | Out-Null
    Exit 1
    }

