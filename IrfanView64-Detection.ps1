# Continue Silently on Error
$ErrorActionPreference = 'SilentlyContinue'

# Wait for Uninstall 
Wait-Process -Name 'iv_uninstall'

If ($(Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\IrfanView64 | Select-Object -ExpandProperty DisplayVersion) -eq '4.60')
    {
    # Application Installed
    Write-Host $True
    Exit 0
    }

    # Application Not installed
Else 
    {
    Exit 0
    }