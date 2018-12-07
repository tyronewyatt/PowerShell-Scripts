<#
.Synopsis
    Set OEM Product Key
	
.Description
    Set Original Equipment Manufacturer Product Key using Windows Management Instrumentation

.Notes
    File Name      : SetOEMProductKey.ps1
    Author         : Tyrone Wyatt (tyrone.wyatt@gmail.com)
    Prerequisite   : PowerShell V3 over Windows 7 and upper
    Copyright      : Tyrone Wyatt 2018
	Version        : 1.1
	Creation Date  : 07/12/2018
	Purpose/Change : Check key and activate with switch

.Link
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/

.Example
    SetOEMProductKey.ps1
 #>
Param(
    [switch]$Activate
)

# Get OEM Product Key
$ProductKey = (Get-WmiObject -Class SoftwareLicensingService).OA3xOriginalProductKey

# Validate Product Key
If ($ProductKey -Match '^([A-Z0-9]{5}-){4}[A-Z0-9]{5}$')
    {
    # Install Product Key
    Invoke-Expression "cscript /b $Env:WinDir\System32\slmgr.vbs /ipk $ProductKey"
    }

# Activate Windows
If ($Activate)
    {
    Invoke-Expression "cscript /b $Env:WinDir\System32\slmgr.vbs /ato"
    }