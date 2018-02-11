<#
Active Directory user account passwords must meet the following minimum requirements:
1) Not contain the user's account name or parts of the user's full name that exceed two consecutive characters
2) Be at least six characters in length
3) Contain characters from three of the following four categories:
	a) English uppercase characters (A through Z)
	b) English lowercase characters (a through z)
	c) Base 10 digits (0 through 9)
	d) Non-alphabetic characters (for example, !, $, #, %)
Complexity requirements are enforced when passwords are changed or created.
 #>

# Import module
Add-Type -AssemblyName System.web

# Set variables
$PasswordLength = '7'
$AccountName = 'DRA0003'
$FullName = 'Daniel DRAGE'

# Ensure password length is met
If ($PasswordLength -lt '6') {} Else {$PasswordLength = '6'}

# Ensure account name not exceed two consecutive characters
$AccountNameLength = $AccountName.Length
Do { 
	$AccountNamePasswordDoCount++
	$AccountNamePasswordVariable = $AccountName.Substring($AccountNamePasswordDoCount-1,3)
	$AccountNamePasswordArray += ("$AccountNamePasswordVariable|")
	} 
While ($AccountNamePasswordDoCount -ne $AccountNameLength-2) 

# Ensure full name not exceed two consecutive characters
$FullNameLength = $FullName.Length
Do { 
	$FullNamePasswordDoCount++
	$FullNamePasswordVariable = $FullName.Substring($FullNamePasswordDoCount-1,3)
	$FullNamePasswordArray += ("$FullNamePasswordVariable|")
	}
While ($FullNamePasswordDoCount -ne $FullNameLength-2) 

# Generate password with at least 1 non-alphabetic characters and ensure all requirements are met
Do {
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	}
Until (
	$ComplexPassword -Match '[0-9]' -And `
	$ComplexPassword -CMatch '[a-z][A-Z]' -And `
	$ComplexPassword -NotMatch '[0|o|1|i|l]' -And `
	$ComplexPassword -NotMatch "[$AccountNamePasswordArray]|[$FullNamePasswordArray]"
	)

# Display password to screen
Write-Host $ComplexPassword

