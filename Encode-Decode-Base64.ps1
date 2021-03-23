# Encode to Base64
$String = "SecretMessage"
[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($String))

# Decpde from Base64
$String = "U2VjcmV0TWVzc2FnZQ=="
[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($String))