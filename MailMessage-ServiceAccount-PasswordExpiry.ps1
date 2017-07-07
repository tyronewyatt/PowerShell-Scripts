Import-Module ActiveDirectory

$MaximumPasswordAge = '365'
$WarningPasswordAge = '14'
$OrganisationalUnit = 'OU=Services,OU=Domain Users,DC=tallangatta-sc,DC=vic,DC=edu,DC=au'
$SmtpServer = 'tscmx01.tallangatta-sc.vic.edu.au'
$MailTo = 'Netbook Admin <tw@tallangatta-sc.vic.edu.au>'
$MailFrom = 'ADUser-Expiry-Temporary-Password <tscdc01@tallangatta-sc.vic.edu.au>'

$Users = Get-ADUser `
	-SearchBase $OrganisationalUnit `
	-Filter {Enabled -eq $True} `
	-Properties samAccountName,pwdLastSet

ForEach ($User In $Users)
{
	$samAccountName = $User.'samAccountName'
	$pwdLastSet = [datetime]::fromFileTime($User.'pwdLastSet')
	$PasswordAgeDays = (New-TimeSpan -Start $pwdLastSet -End (Get-Date)).days
	$DaysToExipre = $MaximumPasswordAge-$PasswordAgeDays
	$DaysExpired = $DaysToExipre.ToString().SubString(1)
	
If 	($Users | Where-Object `
		{ `
		$DaysToExipre -le $WarningPasswordAge
		}
	)
	{
	If ($DaysToExipre -le $WarningPasswordAge -And `
		$DaysToExipre -ge '2')
		{
		Write-Host "$samAccountName password expires in $DaysToExipre days."
		$MailBody += @("`n$samAccountName password expires in $DaysToExipre days.")
		}
	ElseIf ($DaysToExipre -eq '1')
		{
		Write-Host "$samAccountName password expires tomorrow."
		$MailBody += @("`n$samAccountName password expires tomorrow.")
		}
	ElseIf ($DaysToExipre -eq '0')
		{
		Write-Host "$samAccountName password expired today."
		$MailBody += @("`n$samAccountName password expired today.")
		}
	ElseIf ($DaysToExipre -le '-1')
		{
		Write-Host "$samAccountName password expired $DaysExpired days ago."
		$MailBody += @("`n$samAccountName password expired $DaysExpired days ago.")
		}
	}
}

If ($MailBody -ne $Null)
	{
	$NumberAccountsDisabled = ($MailBody).count
	If (($MailBody).count -eq '1') 
		{$MailSubject = "$NumberAccountsDisabled Service Account requires new password"}
		Else
		{$MailSubject = "$NumberAccountsDisabled Service Accounts requires new passwords"}
	ForEach ($MailBody In $MailBodys)
		{
		$MailBody = $MailBody
		}
	Send-MailMessage `
		-To "$MailTo" `
		-From "$MailFrom" `
		-Subject "$MailSubject" `
		-SmtpServer "$SmtpServer" `
		-Body "$MailBody"
	}