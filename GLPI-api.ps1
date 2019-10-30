
$ContentType = 'application/json'
$UserToken = 'user_token okYsuH6Z0xunxAQlOpcfQ4SYAPbujxgQ8jI7vuvp'
$AppToken = 'AzLVtjC1ltRqXpsSBExv3NmxyBSp5Tmjj1NpzjPZ'
$AppURL = 'https://helpdesk.tallangatta-sc.vic.edu.au/apirest.php'

#initSession
$SessionToken = Invoke-RestMethod -Method Get "$AppURL/initSession/" -Headers @{"Content-Type"=$ContentType;"Authorization"=$UserToken;"App-Token"=$AppToken}

#getMyProfiles
#Invoke-RestMethod -Method Get "$AppURL/getMyProfiles/" -Headers @{"Content-Type"=$ContentType;"Session-Token"=$SessionToken.session_token;"App-Token"=$AppToken}


$json = Invoke-RestMethod -Method Get "$AppURL/User/" -Headers @{"Content-Type"=$ContentType;"Session-Token"=$SessionToken.session_token;"App-Token"=$AppToken;"Accept-Range"="max"}
$json | Select-Object name, comment

Invoke-RestMethod -Method Get "$AppURL/Computer/?expand_dropdowns=true" -Headers @{"Content-Type"=$ContentType;"Session-Token"=$SessionToken.session_token;"App-Token"=$AppToken;"Accept-Range"="max"}


#killSession
Invoke-RestMethod -Method Get "$AppURL/killSession/" -Headers @{"Content-Type"=$ContentType;"Session-Token"=$SessionToken.session_token;"App-Token"=$AppToken}