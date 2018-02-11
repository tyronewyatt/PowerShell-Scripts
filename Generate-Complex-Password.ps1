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

# Compliance - Be at least six characters in length
If ($PasswordLength -NotIn 6..32) {$PasswordLength = '7'}

# Compliance - Not contain the user's account name or parts of the user's full name that exceed two consecutive characters
Function NameCompliance {
$NameComplianceString = $Args[0]
$NameComplianceLength = $NameComplianceString.Length
Do { 
	$NameComplianceDoCount++
	$NameComplianceVariable = $NameComplianceString.Substring($NameComplianceDoCount-1,3)
	$NameComplianceArray += ("$NameComplianceVariable|")
	} 
While ($NameComplianceDoCount -ne $NameComplianceLength-2) 
Write-Output $NameComplianceArray
}
$NameCompliance = $(NameCompliance $AccountName)+$(NameCompliance $FullName).Substring(0,$(NameCompliance $FullName).Length-1)

# Generate password until compliance met
Do {
	$ComplexPassword = [System.Web.Security.Membership]::GeneratePassword($PasswordLength,1)
	}
Until (
	# Compliance - English uppercase characters (A through Z)
	$ComplexPassword -CMatch '[A-Z]' -And `
	`
	# Compliance - English lowercase characters (a through z)
	$ComplexPassword -CMatch '[a-z]' -And `
	`
	# Compliance - Base 10 digits (0 through 9)
	$ComplexPassword -Match '[0-9]' -And `
	`
	# Compliance - Easy to read
	$ComplexPassword -CNotMatch '[0|o|I|l]' -And `
	`
	# Compliance - Not contain the user's account name or parts of the user's full name that exceed two consecutive characters
	$ComplexPassword -NotMatch $NameCompliance
	)

# Display password to screen
Write-Host $ComplexPassword

