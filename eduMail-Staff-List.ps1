$SearchBase = 'OU=North Eastern Victoria Region,OU=Users,OU=Schools,DC=education,DC=vic,DC=gov,DC=au'
[ValidateLength(4,4)]$SchoolID = [string](Read-Host -Prompt 'Enter school number')
$Domain = 'edu001'
$Username = Read-Host "Enter Username [$Domain]"
$Password = Read-host 'Enter Password' -AsSecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $Domain\$Username,$Password
$Date = (get-date).ToString("yyyy-mm-dd")
$Path = ".\$SchoolID Staff List $Date.csv"

Write-Host 'Getting Users from Active Directory '
Get-ADUser `
	-Server '10.135.12.20' `
    -Credential $Credential `
	-SearchScope Subtree -SearchBase $SearchBase `
	-filter {Enabled -Eq $True -And mail -Like '*' -And extensionAttribute5 -Like $SchoolID} `
	-properties `
        displayName, `
        Title, `
        mail | `
	sort-object `
        Surname | `
	select-object `
		SamAccountName, `
		Surname, `
		GivenName, `
		displayName, `
		mail, `
        Title | `
	Export-csv `
		-NoTypeInformation `
		-Path $Path
If ($?) {Write-Host "Exported $Path"}