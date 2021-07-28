If ((Get-Service -Name 'WlanSvc').Status -Eq 'Running')
    {
    $WlanInterfaces = netsh wlan show interfaces
    $WlanState = ($WlanInterfaces | Select-String 'State') -replace '.*:\s',''
    $WlanSSID = ($WlanInterfaces | Select-String ' SSID ') -replace '.*:\s',''
    If ($WlanState -Eq 'connected')
        {netsh wlan set profileparameter name="$WlanSSID" connectionmode=auto}
    }