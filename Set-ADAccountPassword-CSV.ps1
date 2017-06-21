Import-Module ActiveDirectory   

$Users = Import-Csv -Delimiter "," -Path ".\Set-ADAccountPassword.csv"
foreach ($User in $Users)
{
    $AccountName = $User.'AccountName'
    $Password = $User.'Password'
	Set-ADAccountPassword -Identity "$AccountName" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
	Set-AdUser -Identity "$AccountName" -ChangePasswordAtLogon $true
}
