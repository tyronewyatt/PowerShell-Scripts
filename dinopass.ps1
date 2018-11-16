<#
.Synopsis
    Commandline interface for dinopass.com
	
.Description
    Create multiple simple or strong passwords and display on screen or export to file.

.Notes
    File Name      : dinopass.ps1
    Author         : Tyrone Wyatt (tyrone.wyatt@gmail.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : Tyrone Wyatt 2018
	Version        : 1.2
	Creation Date  : 16/11/2018
	Purpose/Change : First stable build with added function module

.link
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/

.Example
	# Create 1 simple password
    dinopass.ps1 -quantity 1

.Example
	# Create 5 strong passwords
    dinopass.ps1 -quantity 5 -complex

.Example
	# Create 30 strong passwords and export to CSV
    dinopass.ps1 -quantity 30 -complex -export
 #>
# Set varibles
Param(
	[Int]$Quantity = '1',
    [switch]$Complex,
    [switch]$Export
)

# Set default password strength
If ($Complex -Eq $True) {$Strength = 'strong'}
Else
{$Strength = 'simple'}

# Set dinopass API URL
$DinoPassURL = 'https://dinopass.com/password'

# Generate multiple passwords from website
$Passwords = For($Counter=1
    $Counter -le $Quantity
    $Counter++){
        Invoke-WebRequest $DinoPassURL/$Strength
    }

# Change title from Content to Password
$Passwords = $Passwords | Add-Member -MemberType AliasProperty -Name Password -Value Content -PassThru

# Change title from RawContentLength to PasswordLength
$Passwords = $Passwords | Add-Member -MemberType AliasProperty -Name PasswordLength -Value RawContentLength -PassThru

# Export to CSV
If ($Export -Eq $True)
    {$Passwords | Select-Object Password, PasswordLength | Export-CSV -NoTypeInformation -Path .\dinopass.csv}

# Write to Screen
Write-Output $Passwords | Select-Object Password
