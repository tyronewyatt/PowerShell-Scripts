#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '6/8/2021 11:18:32 AM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "SCC" # Site code 
$ProviderMachineName = "dcsvsccm01" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams


#
$CMCollectionName = 'Dell Latitude 5289'

$CMusers = Get-CMCollectionMember -CollectionName $CMCollectionName -Name * | Select-Object *
$ADusers = Get-ADUser -SearchBase 'OU=Standard,OU=Users,OU=SCC,DC=shellharbour,DC=nsw,DC=gov,DC=au' -Filter * -Properties Office, Title

Foreach ($CMuser in $CMusers) {
    $ComputerUserName = $CMuser.'username'
    $ComputerName = $CMuser.'name'
    Foreach ($ADuser in $ADusers) {
    $UserSamAccountName = $ADuser.'SamAccountName'
    $UserName = $ADuser.'name'
    $UserOffice = $ADuser.'Office'
    $UserTitle = $ADuser.'title'
    $UserDescription = $ADuser.'Description'
    $OutPut = @()
    If ($UserSamAccountName -eq $ComputerUserName) {$OutPut += [PSCustomObject] @{ComputerName=$ComputerName;UserName=$UserName;UserOffice=$UserOffice;UserTitle=$UserTitle}}
    Write-Output $OutPut
    }
}
