Import-Module ActiveDirectory

$Users = Import-Csv -Delimiter "," -Path ".\New-ADUser-Import.csv"
foreach ($User in $Users)
{
    $DisplayName = $User.'FirstName' + " " + $User.'LastName'
    $UserFirstName = $User.'FirstName'
    $UserLastName = $User.'LastName'
    $OrganisationalUnit = $User.'OrganisationalUnit'
    $AccountName = $User.'AccountName'
    $PrincipalName = $User.'AccountName' + "@" + $User.'DomainName'
    $Description = $User.'Description'
    $Password = $User.'Password'
    $GroupMember = $User.'$GroupMember'
    New-ADUser -Name "$AccountName" -DisplayName "$DisplayName" -SamAccountName $AccountName -UserPrincipalName $PrincipalName -GivenName "$UserFirstName" -Surname "$UserLastName" -Description "$Description" -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -Force) -Enabled $true -Path "$OrganisationalUnit" -ChangePasswordAtLogon $true –PasswordNeverExpires $false -AllowReversiblePasswordEncryption $false
    Add-ADGroupMember -Identity "$AccountName" "$GroupMember"
}
