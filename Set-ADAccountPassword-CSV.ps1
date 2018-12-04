<#
.Synopsis
    Set AD account passwords.
	
.Description
    Set active direcory account password from CSV.

.Notes
    File Name      : Set-ADAcountPassword-CSV.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V3 over Windows 7 and upper
    Copyright      : 2018 - Tyrone Wyatt - Department of Education & Training Victoria
	Version        : 1.1
	Creation Date  : 04/12/2018
	Purpose/Change : First stable build with comments
.Link
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/

.Example
	# Set AD account password from CSV
    Set-ADAccountPassword-CSV.ps1

.Example
	# Set AD account password from CSV with path
    Set-ADAccountPassword-CSV.ps1 -InFile 'C:\users.csv'

.Example
	# Set AD account password from CSV with path and change password t next logon 
    Set-ADAccountPassword-CSV.ps1 -InFile 'C:\users.csv'
 #>
# Set varibles
Param(
    [string]$InFile = '.\Set-ADAccountPassword.csv',
    [switch]$ChangePasswordAtLogon
)
# Import modules
Import-Module ActiveDirectory

# Import users from CSV
$Users = Import-Csv -Delimiter "," -Path $InFile
$Count = ($Users).Count

# Set password for each user in CSV
ForEach ($User In $Users)
    {
    # Set varibles
    $Identity = $User.'Username'
    $Password = $User.'Password'
    
    #Counter
    $Counter=1;$Counter -le $Count;$Counter++
    
    #Progress
    Write-Progress -Activity 'Setting password' -Status "$Counter/$Count" -PercentComplete ($Counter/$Count*100)

    #Set passwords
	Set-ADAccountPassword `
		-Identity $Identity `
		-Reset `
		-NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force) `
        -Passthru

    # Change password at logon if enabled
    If ($ChangePasswordAtLogon) 
	    {Set-AdUser `
		    -Identity $Identity `
            -CannotChangePassword $False `
		    -ChangePasswordAtLogon $True1
        }
    }