# School ID
[ValidateLength(4,4)]$SchoolID = [string](Read-Host -Prompt 'Enter school number')

# Domain
$Domain = 'edu001'

# Domain Controller
$DomainControllerFQDN = $SchoolID + "edudc01.education.vic.gov.au"
Write-Host 'Resolving domain controller...'
Try 
    {$ResolveDnsName = Resolve-DnsName $DomainControllerFQDN -Server 10.10.22.11,10.10.22.12 -ErrorAction Stop}
Catch 
    {
    Write-Warning -Message "$DomainControllerFQDN DNS name does not exist."
    Write-Host -ForegroundColor Red "Goodbye!"
    Exit
    }
Finally 
    {
    $DomainControllerIP = ($ResolveDnsName).IPAddress
    }
Write-Host -ForegroundColor Green "Domain controller set to $DomainControllerFQDN [$DomainControllerIP]."


# Credentials
$Username = Read-Host "Enter Username [$Domain]"
$Password = Read-host 'Enter Password' -AsSecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $Domain\$Username,$Password

# SearchBase
Write-Host "Detecting active directory search base..."
$SchoolAccountID = 's' + $SchoolID + '01'
Try 
    {
    $SchoolAccount = Get-ADUser `
        -Server $DomainControllerIP `
        -Credential $Credential `
        -Identity $SchoolAccountID `
        -Properties Office `
        -ErrorAction Stop
    }
Catch 
    {
    Write-Warning -Message "Error getting user $Domain\$Username"
    Write-Host -ForegroundColor Red "Goodbye!"
    Exit
    }
Finally 
    {
    $SchoolAccountDN = $SchoolAccount.DistinguishedName
    $SchoolOffice = $SchoolAccount.Office
    $SearchBase = $SchoolAccountDN.Substring($SchoolAccountDN.IndexOf(',OU=')+1)
    }
Write-Host -ForegroundColor Green "Search base set to $SearchBase."

# Get AD Users
Write-Host 'Getting users for' $SchoolOffice 'from active directory...'
Try 
    {
    $ADUsers = Get-ADUser `
	    -Server $DomainControllerIP `
        -Credential $Credential `
	    -SearchScope Subtree -SearchBase $SearchBase `
    	-Filter {Enabled -Eq $True -And mail -Like '*' -And extensionAttribute5 -Like $SchoolID} `
	    -Properties `
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
            Title `
        -ErrorAction Stop
    }
Catch 
    {
    Write-Warning -Message "Error getting users"
    Write-Host -ForegroundColor Red "Goodbye!"
    Exit
    }
If ($?) {Write-Host -ForegroundColor Green "Found" ($ADUsers).Count "users."} Else {Break}

# Export CSV
Write-Host 'Exporting CSV...'
$Date = (Get-Date).ToString("yyyy-MM-dd")
$Path = "$SchoolOffice Staff List $Date.csv"
$ADUsers | Export-csv `
		-NoTypeInformation `
		-Path $Path
If ($?) {Write-Host -ForegroundColor Green "Exported $(Get-Location)\$Path"}