<#
.Synopsis
    Commandline interface for dinopass.com
	
.Description
    Create multiple simple or strong passwords and display on screen or export to file.

.Notes
    File Name      : dinopass.psm1
    Author         : Tyrone Wyatt (tyrone.wyatt@gmail.com)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : Tyrone Wyatt 2018
	Version        : 1.1
	Creation Date  : 14/11/2018
	Purpose/Change : First stable build with added function module

.link
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/

.Example
	# Create 1 simple password
    dinopass -quantity 1 -strength simple

.Example
	# Create 5 strong passwords
    dinopass -quantity 5 -strength strong 

.Example
	# Create 30 strong passwords and export to CSV
    dinopass -quantity 30 -strength strong -export yes
 #>
# Set varibles
Function dinopass
{
    Param(
   	    [String]$Quantity = $(Read-Host 'Password Quantity [1]'),
        [String]$Strength = $(Read-Host 'Password Strength [SIMPLE/Strong]'),
        [String]$Export = $(Read-Host 'Export to CSV [Yes/NO]')
    )

    # Set default password quantity
    If (!$Quantity) {$Quantity = '1'}

    # Set default password strength
    If ($Strength -Ne 'strong') {$Strength = 'simple'}

    # Set default export rule
    If ($Export -Ne 'yes') {$Export = 'no'}

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
    If ($Export -Eq 'yes')
        {$Passwords | Select-Object Password, PasswordLength | Export-CSV -NoTypeInformation -Path .\dinopass.csv}

    # Write to Screen
    Write-Output $Passwords | Select-Object Password
}
Export-ModuleMember -Function dinopass