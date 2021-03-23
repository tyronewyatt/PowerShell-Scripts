$FirewallProfile = netsh advfirewall monitor show currentprofile
Try {If ($FirewallProfile -match "Public Profile:") 
        {Restart-Service -name NlaSvc -Force}
}
Catch {exit 1}
Finally {exit 0}