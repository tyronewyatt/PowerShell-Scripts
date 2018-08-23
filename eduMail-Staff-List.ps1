<#
.SYNOPSIS
    Export staff details from active directory.
.DESCRIPTION
    Export staff firstname, lastname, email address and title from active directory.
.NOTES
    File Name      : eduMail-Staff-List.ps1
    Author         : T Wyatt (wyatt.tyrone.e@edumail.vic.gov.au)
    Prerequisite   : PowerShell V2 over Vista and upper.
    Copyright      : 2018 - Tyrone Wyatt / Department of Education Victoria
.LINK
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/
.EXAMPLE
    .\eduMail-Staff-List.ps1
 #>

# School ID
Do {$SchoolID = Read-Host 'Enter school number'}
Until ($SchoolID -Match '^[0-9]{4}$')

# Domain
$Domain = 'edu001'

# Domain Controller
$DomainControllerFQDN = $SchoolID + "edudc01.education.vic.gov.au"
Write-Host 'Resolving domain controller...'
Try 
    {$ResolveDnsName = Resolve-DnsName $DomainControllerFQDN -Server 10.10.22.11,10.10.22.12 -ErrorAction Stop}
Catch 
    {
	Write-Host -ForegroundColor Red -BackgroundColor Black $Error[0]
	Break 
    }
$DomainControllerIP = ($ResolveDnsName).IPAddress
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
    Write-Host -ForegroundColor Red -BackgroundColor Black $Error[0]
    Break
    }
$SchoolAccountDN = $SchoolAccount.DistinguishedName
$SchoolOffice = $SchoolAccount.Office
$SearchBase = $SchoolAccountDN.Substring($SchoolAccountDN.IndexOf(',OU=')+1)
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
    Write-Host -ForegroundColor Red -BackgroundColor Black $Error[0]
	Break
    }
Write-Host -ForegroundColor Green "Found" ($ADUsers).Count "users."


# Export CSV
Write-Host 'Exporting CSV...'
$Date = (Get-Date).ToString("yyyy-MM-dd")
$Path = "$SchoolOffice Staff List $Date.csv"
$ADUsers | Export-csv `
		-NoTypeInformation `
		-Path $Path
If ($?) {Write-Host -ForegroundColor Green "Exported $(Get-Location)\$Path"}