
$Users = Get-ADuser -SearchBase "OU=Student,OU=Domain Users,DC=curric,DC=domain,DC=wan" -filter {proxyAddresses -Like '*'} -Properties proxyaddresses 

ForEach ($User In $Users)
    {
    $Name = $User.'DistinguishedName'
    Set-ADUser -Identity $Name -Clear ProxyAddresses -PassThru
    }