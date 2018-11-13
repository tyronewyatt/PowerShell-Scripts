Param(
    [String]$Quantity = $(Read-Host 'Password Quantity'),
	[String]$Export = $(Read-Host 'Export CSV [Yes/NO]')
	)
$Passwords = For($Counter=1
    $Counter -le $Quantity
    $Counter++){
        Invoke-WebRequest https://dinopass.com/password/simple
        }

If ($Export -Eq 'Yes')
	{$Passwords | Select-Object Content, RawContentLength | Export-CSV -NoTypeInformation -Path .\dinopass.csv}
$Passwords | Select-Object Content