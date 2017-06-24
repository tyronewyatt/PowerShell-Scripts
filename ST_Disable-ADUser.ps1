Import-Module ActiveDirectory

$SchoolNumber='8370'
$StudentsOrganisationalUnit='OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$ExistingStudents = Get-ADUser -SearchBase $StudentsOrganisationalUnit -Filter {Enabled -eq $True} -Properties samAccountName,Description

$Students = Import-Csv -Delimiter "," -Path ".\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'LEFT|DEL'}
ForEach ($Student In $Students)
{
    $AccountName = $Student.'STKEY'
	$ExitDate = $Student.'EXIT_DATE'
	$Description = $_.Description
	if (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -ne $null)
        {
		#Set-ADUser -Identity $AccountName -Description "$Description - Exit date $ExitDate"
		#Disable-ADAccount -Identity $AccountName
		Write-Host $AccountName $Description - Exit date $ExitDate
		}
}