Start-Transcript "$($env:windir)\temp\Realtek-High-Definition-Audio-Driver_88MRG_WIN_6.0.9107.1_A26.log"

$DriverVersion = Get-WmiObject Win32_PnPSignedDriver | Where-Object {$_.DeviceName -Eq "Realtek Audio"} | Select-Object -ExpandProperty DriverVersion 

# Application Install
If ($DriverVersion -Lt "6.0.9107.1") 
    {
    Get-ChildItem ".\" -Recurse -Filter "*.inf" | ForEach-Object {& PNPUtil.exe /install /add-driver $_.FullName}
    Stop-Transcript
    Exit 3010
    }

# Application Installed
ElseIf ($DriverVersion -Ge "6.0.9107.1") 
    {
    Write-Host $True
    Stop-Transcript
    Exit 0
    }

# Application Unknown
Else 
    {
    Stop-Transcript | Out-Null
    Exit 1
    }
