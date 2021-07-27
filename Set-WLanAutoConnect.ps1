If (((& netsh wlan show interfaces | Select-String State) -replace '.*:\s','') -Eq 'connected')
    {
    $SSID = (& netsh wlan show interfaces | Select-String ' SSID') -replace '.*:\s',''
    & netsh wlan set profileparameter name="$SSID" connectionmode=auto
    }