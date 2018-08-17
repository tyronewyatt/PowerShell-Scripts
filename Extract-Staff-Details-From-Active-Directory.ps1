$SearchBase = 'OU=North Eastern Victoria Region,OU=Users,OU=Schools,DC=education,DC=vic,DC=gov,DC=au'
$Path = '.\Extract-Staff-Details-From-Active-Directory.csv'
$SchoolID = '8370'

Get-ADUser `
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