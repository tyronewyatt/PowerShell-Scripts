Param(
	[Int]$Count = '1',
    [switch]$Strong,
    [string]$OutFile
)

[Reflection.Assembly]::LoadWithPartialName("System.Web")

# Set password strength
If ($Strong) 
    {
    $PasswordLength = '12'
    $PasswordNumOfNonAlphaChas = '1'
    }
Else 
    {
    $PasswordLength = '6'
    $PasswordNumOfNonAlphaChas = '0'
    }

# Generate multiple passwords from website
$Passwords = For($Counter=1;$Counter -le $Count;$Counter++) 
        {
        $ProgressPreference = 'Continue'
        Write-Progress `
            -Activity 'Generating' `
            -Status "$Counter/$Count" `
            -PercentComplete ($Counter/$Count*100)
        $ProgressPreference = 'SilentlyContinue'
        [System.Web.Security.Membership]::GeneratePassword($PasswordLength,$PasswordNumOfNonAlphaChas)
        }

# Export to CSV or write to screen
If ($OutFile) 
    {$Passwords | Export-CSV -NoTypeInformation -Path $OutFile -Confirm}
Else
    {Write-Output $Passwords}
