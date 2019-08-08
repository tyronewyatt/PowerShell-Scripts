<#
.Synopsis
    Bulk delete wireless certificates.
	
.Description
    Bulk delete wireless certificates AD computers from edu002. The opersite to the eduSTAR.NET Connection Utility - Create bulk certificates.

.Notes
    File Name      : DeleteBulkCertificates.ps1
    Author         : Tyrone Wyatt (tyrone.wyatt@gmail.com)
    Prerequisite   : PowerShell V4 over Windows 8.1 and upper
    Copyright      : Tyrone Wyatt 2019
	Version        : 1.0.0
	Creation Date  : 08/08/2019
	Purpose/Change : Finalized paramaters, output to screen or CSV but not both and progress bar

.Link
    Repository     : https://github.com/tyronewyatt/PowerShell-Scripts/

.Example
	# Bulk Delete Certificates
    DeleteBulkCertificates.ps1

.Example
	# Custom CSV
    DeleteBulkCertificates.ps1 -InFile 'C:\file.csv'

.Example
	# Custom school and CSV
    DeleteBulkCertificates.ps1 -InFile 'C:\file.csv' -SchoolID '1234'
 #>
# Set varibles
Param(
    [string]$InFile = '.\DeleteBulkCertificates.csv',
    [string]$SchoolID = '8843'
)
Clear-Host

Import-Module ActiveDirectory

# Import certs from CSV
$Certs = Import-Csv -Delimiter "," -Path $InFile

#Create Counter
$Count = ($Certs).Count
$Counter=1

# Delete computer for each user in CSV
ForEach ($Cert In $Certs)
    {
    # Set varibles
    $ComputerName = $Cert.'ADComputer'  
        
    #Progress
    Write-Progress -Activity 'Removing AD Computer' -Status "$Counter/$Count" -PercentComplete ($Counter/$Count*100)

    #Remove AD Computers
	Get-ADComputer -Identity "$SchoolID-$ComputerName" | Remove-ADComputer -Confirm:$False

    #Increase Counter
    $Counter++
    }