Start-Transcript "$($env:windir)\temp\Realtek-High-Definition-Audio-Driver_88MRG_WIN_6.0.9107.1_A26.log"

$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq "Realtek Audio"}
$ComputerSystem = Get-WmiObject Win32_ComputerSystem

If ($ComputerSystem.Manufacturer -Like 'Dell*' -And $ComputerSystem.Model -Match 'Latitude 7280|Latitude 7290|Latitude 7380|Latitude 7390|Latitude 7480|Latitude 7490')
    {
    # Application Install
    If ($PnPSignedDriver.DriverVersion -Lt '6.0.9107.1') 
        {
        Get-ChildItem ".\" -Recurse -Filter "*.inf" | ForEach-Object {& PNPUtil.exe /install /add-driver $_.FullName}
        Stop-Transcript
        Exit 3010
        }

    # Application Installed
    ElseIf ($PnPSignedDriver.DriverVersion -Ge '6.0.9107.1') 
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

