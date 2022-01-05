$ChromeFile32 = "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
$ChromeFile64 = "$env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$ChromeVersion = '92.0.4515.131'

If (Test-Path $ChromeFile64) {$ChromeFile = $ChromeFile64}
ElseIf (Test-Path $ChromeFile32) {$ChromeFile = $ChromeFile32}
Else {$ChromeFile = $Null}

If (($ChromeFile) -And ((Get-Item $ChromeFile).VersionInfo.FileVersion -Ge $ChromeVersion))
    {
    # Application Installed
    Write-Host $True
    Exit 0
    }

    # Application Not installed
Else 
    {Exit 0}
