<#
Uninstall String Examples
MSI:    MsiExec.exe /X{61D674B3-02A0-3DFF-8A11-08170BB9007B}
EXE:    "C:\Program Files (x86)\Microsoft\Edge\Application\97.0.1072.55\Installer\setup.exe" --uninstall --system-level --verbose-logging --force-uninstall
#>

#Get Version
$EdgeVersions = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall  |
    Get-ItemProperty |
    Where-Object {$_.DisplayName -eq "Microsoft Edge" } |
    Select-Object -Property DisplayName, UninstallString

ForEach ($EdgeVersion in $EdgeVersions) 
    {
    If ($EdgeVersion.UninstallString)
        {
        $UninstallCommand = $EdgeVersion.UninstallString 

        # Uninstall MSI
        If ($UninstallCommand -Like '*msiexec.exe*')
            {
            & cmd /c $UninstallCommand /q
            }

        # Uninstall EXE 
        ElseIf ($UninstallCommand -Like '*Program*Files*setup.exe*')
            {
            Do {Stop-Process -Name 'MSEdge' -Force -ErrorAction SilentlyContinue} 
            While (Get-Process -Name 'MSEdge' -ErrorAction SilentlyContinue)
            & cmd /c $UninstallCommand --force-uninstall --system-level
            If ($LASTEXITCODE -Eq '19') {$LASTEXITCODE = '0'}
            }
        }
    }