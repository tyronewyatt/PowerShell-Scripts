<#
.SYNOPSIS
Applies all updates for the current system configuration.

.DESCRIPTION
Dell Command Update is a stand-alone application, for commercial client computers, that provides updates for system software that is released by Dell.
This application simplifies the BIOS, firmware, driver, and application update experience for Dell commercial client hardware.
This application can also be used to install drivers after the operating system and network drivers are installed based on the computer identity.

.LINK
https://www.dell.com/support/manuals/de-ch/command-update/dellcommandupdate_rg/dell-command-%7C-update-cli-commands?guid=guid-92619086-5f7c-4a05-bce2-0d560c15e8ed&l
#>

# Paths
$DellCommandUpdate = "$env:ProgramFiles\Dell\CommandUpdate\dcu-cli.exe"
$LogPath = "$env:ProgramData\Dell\UpdatePackage\Log"
$ActivityLog = "$LogPath\Dell-Command-Update-CLI-Activity_$((Get-Date).ToString("yyyyMMddTHHmmss")).log"

# Update types: bios,firmware,driver,application,others
$UpdateType = "bios,firmware,driver"  

# Test for application
If (!(Test-Path $DellCommandUpdate)) {
    Write-Warning "Application not found!"
    Exit 1
}

Function ReturnCode {
    # Get content from output log
    $ReturnCode = $ProcessOutput | Select-Object -Last 1

    # Extract exit code from exit action and trim whitespace
    $ReturnCode = ($ReturnCode -split ":")[-1].Trim()

    # Output exit code
    Write-Output $ReturnCode
}

Function ReturnDescription {
    # Exit Codes for Dell Command Update version 4.8
    $ReturnCodes = @()
    $ReturnCodes += [PSCustomObject] @{ReturnCode='0';Description='Command execution was successful.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='1';Description='A reboot was required from the execution of an operation.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='2';Description='An unknown application error has occurred.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3';Description='The current system manufacturer is not Dell.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='4';Description='The CLI was not launched with administrative privilege.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='5';Description='A reboot was pending from a previous operation.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='6';Description='Another instance of the same application (UI or CLI) is already running.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='7';Description='The application does not support the current system model.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='8';Description='No update filters have been applied or configured.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='100';Description='While evaluating the command line parameters, no parameters were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='101';Description='While evaluating the command line parameters, no commands were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='102';Description='While evaluating the command line parameters, invalid commands were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='103';Description='While evaluating the command line parameters, duplicate commands were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='104';Description='While evaluating the command line parameters, the command syntax was incorrect.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='105';Description='5While evaluating the command line parameters, the option syntax was incorrect.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='106';Description='While evaluating the command line parameters, invalid options were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='107';Description='While evaluating the command line parameters, one or more values provided to the specific option was invalid.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='108';Description='While evaluating the command line parameters, all mandatory options were not detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='109';Description='While evaluating the command line parameters, invalid combination of options were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='110';Description='While evaluating the command line parameters, multiple commands were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='111';Description='While evaluating the command line parameters, duplicate options were detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='112';Description='An invalid catalog was detected.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='113';Description='While evaluating the command line parameters, one or more values provided exceeds the length limit.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='500';Description='No updates were found for the system when a scan operation was performed.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='501';Description='An error occurred while determining the available updates for the system, when a scan operation was performed.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='502';Description='The cancellation was initiated, Hence, the scan operation is canceled.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='503';Description='An error occurred while downloading a file during the scan operation.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='1505';Description='An error occurred while exporting the application settings.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='1506';Description='An error occurred while importing the application settings.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3000';Description='The Dell Client Management Service is not running.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3001';Description='The Dell Client Management Service is not installed.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3002';Description='The Dell Client Management Service is disabled.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3003';Description='The Dell Client Management Service is busy.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3004';Description='The Dell Client Management Service has initiated a self-update install of the application.'}
    $ReturnCodes += [PSCustomObject] @{ReturnCode='3005';Description='The Dell Client Management Service is installing pending updates.'}
     
    # Select exit description from error code
    $ReturnDescription = $ReturnCodes | Where-Object ReturnCode -Eq (ReturnCode) | Select-Object -ExpandProperty Description

    # Output exit description
    Write-Output $ReturnDescription
}

# Execute and monitor for errors
Try {
    # Set custom configuration
    Start-Process $DellCommandUpdate -ArgumentList "/configure -silent -autoSuspendBitLocker=enable -userConsent=disable -maxretry=2" -Wait -WindowStyle Hidden

    # Applies all updates for the current system configuration
    $ProcessStartInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
        FileName = $DellCommandUpdate
        Arguments = "/applyUpdates -reboot=disable -updateType=$UpdateType -outputlog=$ActivityLog"
        RedirectStandardOutput = $True
        UseShellExecute = $False
        CreateNoWindow = $True
    }
    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $ProcessStartInfo
    $Process.Start() | Out-Null
    $ProcessOutput = $Process.StandardOutput.ReadToEnd()
    $Process.WaitForExit()
}
# Terminating error
Catch {
    Write-Error $_.Exception.Message
    Exit 1
}

# Exit successful, no restart
If ((ReturnCode) -eq 0) {
    Write-Output "The system has been updated."
    Exit 0
}
# Exit successful, restart pending
ElseIf ((ReturnCode) -eq 1) {
    Write-Output "The system has been updated and requires a reboot to complete."
    Exit 3010 
}
# Exit failure
Else {
    Write-Warning (ReturnDescription)
    Exit 1
}