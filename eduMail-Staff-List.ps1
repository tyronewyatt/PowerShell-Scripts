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
Write-Host 'Getting domain controller'
Try 
    {$ResolveDnsName = Resolve-DnsName $DomainControllerFQDN -Server 10.10.22.11,10.10.22.12 -ErrorAction Stop}
Catch 
    {
	Write-Host -ForegroundColor Red -BackgroundColor Black $Error[0]
	Break 
    }
$DomainControllerIP = ($ResolveDnsName).IPAddress
Write-Host -ForegroundColor Green "$DomainControllerFQDN [$DomainControllerIP] domain controller found"

# Credentials
$Username = Read-Host "Enter Username [$Domain]"
$Password = Read-host 'Enter Password' -AsSecureString
$Credential = New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $Domain\$Username,$Password

# School Account
$SchoolAccountID = 's' + $SchoolID + '01'
Try 
    {
	Write-Host 'Getting school details'
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
Write-Host -ForegroundColor Green "Found $SchoolOffice"

# Get Users
Try
    {
	Write-Host 'Getting users'
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
If (($ADUsers).Count -Eq '0') {Write-Warning "No users found"}
ElseIf (($ADUsers).Count -Eq '1') {Write-Host -ForegroundColor Green "Found 1 user"}
Else {Write-Host -ForegroundColor Green "Found" ($ADUsers).Count "users"}

# Export CSV
$Date = (Get-Date).ToString("yyyy-MM-dd")
$Path = "$SchoolOffice Staff List $Date.csv"
Try 
    {
	If (($ADUsers).Count -Gt '0')
		{
		Write-Host 'Exporting staff list'
		If ((Test-Path $Path)) {Remove-Item $Path}
		$ADUsers | Export-csv `
			-NoTypeInformation `
			-Path $Path `
			-ErrorAction Stop
		}
	}
Catch 
    {
    Write-Host -ForegroundColor Red -BackgroundColor Black $Error[0]
	Break
    }
If ((Test-Path $Path)) {Write-Host -ForegroundColor Green "Exported $(Get-Location)\$Path"}