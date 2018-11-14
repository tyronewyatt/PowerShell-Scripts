<#
.SYNOPSIS
    Commandline interface for dinopass.com
.DESCRIPTION
    Create multiple simple or strong passwords and display on screen or export to file.
.NOTES
    File Name      : dinopass.ps1
    Author         : T Wyatt (tyrone.wyatt@gmail.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\dinopass.ps1 -quantity 5 -strength strong 
 #>
# Set varibles
Param(
	[String]$Quantity = $(Read-Host 'Password Quantity [1]'),
    [String]$Strength = $(Read-Host 'Password Strength [SIMPLE/Strong]')
)

# Set default password quantity
If (!$Quantity) {$Quantity = '1'}

# Set default password strength
If ($Strength -Ne 'strong') {$Strength = 'simple'}

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

# Change titlw from RawContentLength to PasswordLength
$Passwords = $Passwords | Add-Member -MemberType AliasProperty -Name PasswordLength -Value RawContentLength -PassThru

# Export to CSV
$Passwords | Select-Object Password, PasswordLength | Export-CSV -NoTypeInformation -Path .\dinopass.csv

# Write to Screen
$Passwords | Select-Object Password