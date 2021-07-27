If (((netsh wlan show interfaces | Select-String 'State') -replace '.*:\s','') -Eq 'connected')
    {
    (netsh wlan show interfaces | Select-String ' SSID') -replace '.*:\s','' | 
    ForEach-Object {netsh wlan set profileparameter name="$_" connectionmode=auto}
    }