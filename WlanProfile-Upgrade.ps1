# WQL for TS
#Get-WmiObject -Namespace 'root\cimv2' -Query "Select * from Win32_Service Where Name = 'WlanSvc' AND State = 'Running'"

# Only run on devices with Wi-Fi
If ((Get-Service -Name 'WlanSvc').Status -Eq 'Running')
    {
    # Get profiles
    $WlanProfiles = (netsh wlan show profiles | Select-String 'All User Profile') -replace '.*:\s',''

    # Remove BYOD profile
    If ($WlanProfiles -Match 'SCC-BYOD') 
        {netsh wlan delete profile name="SCC-BYOD"}

    # Remove Guest profile
    If ($WlanProfiles -Match 'SCC-Guest') 
        {netsh wlan delete profile name="SCC-Guest"}

    # Add Corporate profile
    If (-Not($WlanProfiles -Match 'SCC-Corporate')) 
        {
        netsh wlan add profile filename="Wi-Fi-SCC-Corporate.xml"
        Start-Sleep 10
        }

    # Auto-connect Corporate profile
    $WlanConnectionMode = (netsh wlan show profiles name="SCC-Corporate" | Select-String 'Connection mode') -replace '.*:\s',''
    If ($WlanProfiles -Match 'SCC-Corporate' -And $WlanConnectionMode -Ne 'Connect automatically') 
        {
        netsh wlan set profileparameter name="SCC-Corporate" connectionmode=auto
        Start-Sleep 10
        }

    # Auto-connect current profile
    $WlanState = (netsh wlan show interfaces | Select-String 'State') -replace '.*:\s',''
    $WlanSSID = (netsh wlan show interfaces | Select-String ' SSID ') -replace '.*:\s',''
    $WlanConnectionMode = (netsh wlan show profiles name="$WlanSSID" | Select-String 'Connection mode') -replace '.*:\s',''
    If ($WlanSSID -Ne 'SCC-Corporate' -And $WlanState -Eq 'Connected' -And $WlanConnectionMode -Ne 'Connect automatically')
        {
        netsh wlan set profileparameter name="$WlanSSID" connectionmode=auto
        Start-Sleep 10
        }
}
Exit 0