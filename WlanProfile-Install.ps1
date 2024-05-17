# WQL for TS
#Get-WmiObject -Namespace 'root\cimv2' -Query "Select * from Win32_Service Where Name = 'WlanSvc' AND State = 'Running'"

# Only run on devices with Wi-Fi
If ((Get-Service -Name 'WlanSvc').Status -Eq 'Running')
    {
    # Add Corporate profile
    netsh wlan add profile filename="Wi-Fi-SCC-Corporate.xml"
    }
Exit 0