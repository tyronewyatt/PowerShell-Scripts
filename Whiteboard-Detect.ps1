$DisplayName = "Microsoft.Whiteboard"

$ProvisionedPackages = Get-AppxProvisionedPackage -Online

If ($ProvisionedPackages)
    {
    # Application Installed
    If ($ProvisionedPackages.DisplayName -Like $DisplayName)
        {
        Write-Host $True
        Exit 0
        }

    # Application Not installed
    ElseIf (-Not($ProvisionedPackages.DisplayName -Like $DisplayName))
        {Exit 0}
    }

# Application Unknown
Else 
    {Exit 1}
