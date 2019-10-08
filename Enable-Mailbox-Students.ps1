
$ExchangeServer = 'CORMX02'
$ExchangeUri = "http://$ExchangeServer.corryong.vic.edu.au/PowerShell/"

If ($ENV:ComputerName -eq $ExchangeServer)
    {Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn}
Else
    {$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ExchangeUri -Authentication Kerberos
Import-PSSession $Session -DisableNameChecking -AllowClobber}


Import-Module ActiveDirectory

$OrganisationalUnit = 'OU=Students,OU=Domain Users,DC=corryong,DC=vic,DC=edu,DC=au'
$Database = 'CORMX02-Students'

$Users = Get-ADUser -SearchBase $OrganisationalUnit -Filter * -Properties samAccountName,mail,DistinguishedName
	
ForEach ($User In $Users)
	{
	$AccountName = $User.'SamAccountName'
	$mail = $User.'mail'
	$DistinguishedName = $User.'DistinguishedName'

	If ($User | Where-Object {$mail -eq $null -And $DistinguishedName -like "*OU=[0-9][0-9][0-9][0-9],$OrganisationalUnit"})
			{Enable-Mailbox -Identity $AccountName -Database $Database}
	}

If ($Session.State -Eq 'Opened') {Remove-PSSession $Session}