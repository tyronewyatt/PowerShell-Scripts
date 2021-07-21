Start-Transcript "$($env:windir)\temp\Realtek-High-Definition-Audio-Driver_88MRG_WIN_6.0.9107.1_A26.log"

$PnPSignedDriver = Get-WmiObject Win32_PnPSignedDriver
If ($PnPSignedDriver.DeviceName -Eq "Realtek Audio" -And $PnPSignedDriver.DriverVersion -Lt "6.0.9107.1") 
    {
    Get-ChildItem ".\" -Recurse -Filter "*.inf" | ForEach-Object {& PNPUtil.exe /install /add-driver $_.FullName}
    Stop-Transcript
    Exit 3010
    }
ElseIf ($PnPSignedDriver.DeviceName -Eq "Realtek Audio" -And $PnPSignedDriver.DriverVersion -Ge "6.0.9107.1") 
    {
    Write-Output $True
    Stop-Transcript
    Exit 0
    }
Else 
    {
    Stop-Transcript | Out-Null
    Exit 1
    }
