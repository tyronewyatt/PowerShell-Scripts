<#
.SOURCE 
https://devblogs.microsoft.com/scripting/weekend-scripter-exporting-and-importing-photos-in-active-directory/
#>

$SearchBase = 'OU=Standard,OU=Users,OU=SCC,DC=shellharbour,DC=nsw,DC=gov,DC=au'
$Directory = 'C:\Temp\Pictures'

$Users = Get-ADUser -SearchBase $SearchBase -Filter * -Properties thumbnailPhoto

Foreach ($User in $Users)
    {
        If ($User.thumbnailPhoto)
        
            {
            $FileName = $User.userPrincipalName.ToLower() + '.jpg'

            [System.Io.File]::WriteAllBytes("$Directory\$FileName", $User.thumbnailPhoto)
            }
    }