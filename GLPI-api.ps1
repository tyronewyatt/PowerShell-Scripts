
$ContentType = 'application/json'
$UserToken = 'user_token okYsuH6Z0xunxAQlOpcfQ4SYAPbujxgQ8jI7vuvp'
$AppToken = 'AzLVtjC1ltRqXpsSBExv3NmxyBSp5Tmjj1NpzjPZ'
$AppURL = 'https://helpdesk.tallangatta-sc.vic.edu.au/apirest.php'

#initSession
$SessionToken = Invoke-RestMethod -Method Get "$AppURL/initSession/" -Headers @{"Content-Type"=$ContentType; "Authorization"=$UserToken; "App-Token"=$AppToken}

#Computers
$Computers = Invoke-RestMethod -Method Get "$AppURL/Computer/?range=0-9999&expand_dropdowns=true" -Headers @{"Content-Type"=$ContentType; "Session-Token"=$SessionToken.session_token; "App-Token"=$AppToken; "Accept-Range"="990"}

#Users
$Users = Invoke-RestMethod -Method Get "$AppURL/User/?range=0-9999" -Headers @{"Content-Type"=$ContentType; "Session-Token"=$SessionToken.session_token; "App-Token"=$AppToken;}

ForEach ($Computer In $Computers)
    {
    $ComputerName = $Computer.'Name'
    $ComputerUserid = $Computer.'users_id'

    ForEach ($User In $Users)
    {
    $UserName = $User.'Name'
    $UserComment = $User.'Comment'

    If ($UserName -Like $ComputerUserid -And $userComment -Match 'Leaving|Inactive') {$UserName, $UserComment, $ComputerName -join ","} 
    }
}

#killSession
Invoke-RestMethod -Method Get "$AppURL/killSession/" -Headers @{"Content-Type"=$ContentType; "Session-Token"=$SessionToken.session_token; "App-Token"=$AppToken}