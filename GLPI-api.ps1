
$ContentType = 'application/json'
$UserToken = 'user_token okYsuH6Z0xunxAQlOpcfQ4SYAPbujxgQ8jI7vuvp'
$AppToken = 'AzLVtjC1ltRqXpsSBExv3NmxyBSp5Tmjj1NpzjPZ'
$AppURL = 'https://helpdesk.tallangatta-sc.vic.edu.au/apirest.php'

#initSession
$SessionToken = Invoke-RestMethod `
                    -Method Get "$AppURL/initSession/" `
                    -Headers @{'Content-Type'=$ContentType; 'Authorization'=$UserToken; 'App-Token'=$AppToken}

#Computers
$Computers = Invoke-RestMethod `
                -Method Get "$AppURL/Computer/?range=0-9999&expand_dropdowns=true" `
                -Headers @{'Content-Type'=$ContentType; 'Session-Token'=$SessionToken.session_token; 'App-Token'=$AppToken; "Accept-Range"="990"}

#Users
$Users = Invoke-RestMethod `
            -Method Get "$AppURL/User/?range=0-9999" `
            -Headers @{'Content-Type'=$ContentType; 'Session-Token'=$SessionToken.session_token; 'App-Token'=$AppToken;}

ForEach ($Computer In $Computers)
    {
    $Computer_Name = $Computer.'Name'
    $Computer_Username = $Computer.'users_id'
    $User_Username = $Users | Where-Object {$_.'Name' -Eq $Computer.'users_id'} | Select-Object -ExpandProperty 'Name'
    $User_Comment = $Users | Where-Object {$_.'Name' -Eq $Computer.'users_id'} | Select-Object -ExpandProperty 'Comment'

    If ($User_Username -Like $Computer_Username -And $User_Comment -Match 'Leaving') 
        {
        New-Object psobject -Property @{'Username'=$User_Username; 'User Comment'=$User_Comment; 'Computer'=$Computer_Name} | 
        Select-Object 'Username', 'Computer', 'User Comment'
        }
    }
    

#killSession
Invoke-RestMethod `
    -Method Get "$AppURL/killSession/" `
    -Headers @{'Content-Type'=$ContentType; 'Session-Token'=$SessionToken.session_token; 'App-Token'=$AppToken}