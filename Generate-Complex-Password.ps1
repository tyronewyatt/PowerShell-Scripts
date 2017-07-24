<#
Active Directory use account password must meet complexity requirements.

Passwords must meet the following minimum requirements:

Not contain the user's account name or parts of the user's full name that exceed two consecutive characters
Be at least six characters in length
Contain characters from three of the following four categories:
English uppercase characters (A through Z)
English lowercase characters (a through z)
Base 10 digits (0 through 9)
Non-alphabetic characters (for example, !, $, #, %)
Complexity requirements are enforced when passwords are changed or created.
 #>

#Import modules
Add-Type -AssemblyName System.web

# Set variables
$PasswordLength = '7'
$AccountName = 'DRA0003'
$FullName = 'Daniel DRAGE'

# Generate Password and ensure meets Active Directory complexity requirements
If ($PasswordLength -lt '6') {} Else {$PasswordLength = '6'}
$AccountNameLength = $AccountName.Length
Do { 
	$AccountNamePasswordDoCount++
	$AccountNamePasswordVariable = $AccountName.Substring($AccountNamePasswordDoCount-1,3)
	$AccountNamePasswordArray += ("$AccountNamePasswordVariable|")
	} 
While($AccountNamePasswordDoCount -ne $AccountNameLength-2) 

$FullNameLength = $FullName.Length
Do { 
	$FullNamePasswordDoCount++
	$FullNamePasswordVariable = $FullName.Substring($FullNamePasswordDoCount-1,3)
	$FullNamePasswordArray += ("$FullNamePasswordVariable|")
	}
While($FullNamePasswordDoCount -ne $FullNameLength-2) 

Do {
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	}
Until (
	$ComplexPassword -match '[A-Z]' -And `
	$ComplexPassword -match '[0-9]' -And `
	$ComplexPassword -notmatch "[$AccountNamePasswordArray]|[$FullNamePasswordArray]"
	)
Write-Host $ComplexPassword

