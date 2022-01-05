<#
Uninstall String Examples
MSI:    MsiExec.exe /X{61D674B3-02A0-3DFF-8A11-08170BB9007B}
EXE:    "C:\Program Files\Google\Chrome\Application\92.0.4515.131\Installer\setup.exe" --uninstall --channel=stable --system-level --verbose-logging
#>

#Get Version
$ChromeVersions = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object {$_.DisplayName -match "Chrome" } |
    Select-Object -Property DisplayName, UninstallString

ForEach ($ChromeVersion in $ChromeVersions) 
    {
    If ($ChromeVersion.UninstallString)
        {
        $UninstallCommand = $ChromeVersion.UninstallString 

        # Uninstall MSI
        If ($UninstallCommand -Like '*msiexec.exe*')
            {
            & cmd /c $UninstallCommand /q
            }

        # Uninstall EXE 
        ElseIf ($UninstallCommand -Like '*Program*Files*setup.exe*')
            {
            Do {Stop-Process -Name 'chrome' -Force -ErrorAction SilentlyContinue} 
            While (Get-Process -Name 'chrome' -ErrorAction SilentlyContinue)
            & cmd /c $UninstallCommand --force-uninstall --multi-install --chrome
            If ($LASTEXITCODE -Eq '19') {$LASTEXITCODE = '0'}
            }
        }
    }