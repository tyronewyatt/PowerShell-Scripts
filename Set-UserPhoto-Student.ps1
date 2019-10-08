
$ExchangeServer = 'CORMX02'
$ExchangeUri = "http://$ExchangeServer.corryong.vic.edu.au/PowerShell/"
$OrganisationalUnit = 'OU=Students,OU=Domain Users,DC=corryong,DC=vic,DC=edu,DC=au'
$UserPhotoPath = '\\cordc01\NETLOGON\Photos\Students'

If ($ENV:ComputerName -Eq $ExchangeServer)
    {Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn}
Else
    {$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeUri -Authentication Kerberos
    Import-PSSession $Session -DisableNameChecking -AllowClobber}

Import-Module ActiveDirectory

$Users = Get-ADUser -SearchBase $OrganisationalUnit -Filter * -Properties samAccountName,mail,DistinguishedName

ForEach ($User In $Users)
	{
	$AccountName = $User.'SamAccountName'
	$mail = $User.'mail'
	$DistinguishedName = $User.'DistinguishedName'

	If ($User | Where-Object {$mail -ne $null -And $DistinguishedName -like "*OU=20[0-9][0-9],$OrganisationalUnit" -And (Test-Path "$UserPhotoPath\$AccountName.jpg")})
        {Set-UserPhoto -Identity $AccountName -PictureData ([System.IO.File]::ReadAllBytes("$UserPhotoPath\$AccountName.jpg")) -Confirm:$False}
    ElseIf ($User | Where-Object $DistinguishedName -like "*OU=20[0-9][0-9],$OrganisationalUnit")
        {Remove-UserPhoto -Identity $AccountName -Confirm:$False}
	}

If ($Session.State -Eq 'Opened') {Remove-PSSession $Session}