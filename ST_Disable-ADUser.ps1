Import-Module ActiveDirectory

$SchoolNumber = '8370'
$StudentsOrganisationalUnit = 'OU=Students,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$CSVPath = '\\tscweb02\eduhub$'
$Description = 'Student'

$ExistingStudents = Get-ADUser `
	-SearchBase $StudentsOrganisationalUnit `
	-Filter {Enabled -eq $True} `
	-Properties samAccountName

$Students = Import-Csv -Delimiter "," -Path "$CSVPath\ST_$SchoolNumber.csv" | Where-Object {$_.STATUS -match 'LEFT|DEL'}
ForEach ($Student In $Students)
{
    $AccountName = $Student.'STKEY'
	$DateLeft = $Student.'DATELEFT'
	$Status = $Student.'STATUS'
	if (($ExistingStudents | Where-Object {$_.sAMAccountName -eq $AccountName}) -ne $null)
        {
		Disable-ADAccount `
			-Identity $AccountName
		if($?)
			{
			Set-ADUser `
				-Identity $AccountName `
				-Description "$Description - $Status $DateLeft"
			Write-Host $AccountName 'Disabled. Description' $Description '-' $Status $DateLeft
			}
		}
}
