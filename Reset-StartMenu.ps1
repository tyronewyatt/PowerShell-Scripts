
# Start Menu layout
$LayoutModification = @'
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
  <LayoutOptions StartTileGroupCellWidth="6" />
  <DefaultLayoutOverride>
    <StartLayoutCollection>
      <defaultlayout:StartLayout GroupCellWidth="6">
        <start:Group Name="Microsoft Office">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="2" DesktopApplicationID="Microsoft.Office.ONENOTE.EXE.15" />
          <start:DesktopApplicationTile Size="2x2" Column="4" Row="0" DesktopApplicationID="Microsoft.Office.EXCEL.EXE.15" />
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationID="Microsoft.Office.OUTLOOK.EXE.15" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="2" DesktopApplicationID="Microsoft.Office.POWERPNT.EXE.15" />
          <start:DesktopApplicationTile Size="2x2" Column="2" Row="0" DesktopApplicationID="Microsoft.Office.WINWORD.EXE.15" />
        </start:Group>
        <start:Group Name="Utilities">
          <start:Tile Size="1x1" Column="0" Row="0" AppUserModelID="Microsoft.WindowsCalculator_8wekyb3d8bbwe!App" />
          <start:DesktopApplicationTile Size="1x1" Column="3" Row="0" DesktopApplicationID="Microsoft.SoftwareCenter.DesktopToasts" />
          <start:DesktopApplicationTile Size="1x1" Column="2" Row="0" DesktopApplicationID="{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\SnippingTool.exe" />
          <start:DesktopApplicationTile Size="1x1" Column="1" Row="0" DesktopApplicationID="{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\mspaint.exe" />
        </start:Group>
        <start:Group Name="">
          <start:DesktopApplicationTile Size="2x2" Column="0" Row="0" DesktopApplicationID="MSEdge" />
        </start:Group>
      </defaultlayout:StartLayout>
    </StartLayoutCollection>
  </DefaultLayoutOverride>
</LayoutModificationTemplate>
'@

# -- Apply Machine Customisations -- 
####################################

# Import Default Start Menu layout
$LayoutModification | Out-File "$env:SystemDrive\Users\Default\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding Ascii | Out-Null

####################################

# Get Username, SID, and location of ntuser.dat for all users
$Profiles = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*' | 
    Where-Object { 
        $_.PSChildName -match 'S-1-5-21-\d+-\d+\-\d+\-\d+$'} | 
        Select-Object `
            @{name="SID";expression={$_.PSChildName}}, 
            @{name="UserProfilePath";expression={$_.ProfileImagePath}},
            @{name="UserHive";expression={"$($_.ProfileImagePath)\ntuser.dat"}},
            @{name="Username";expression={$_.ProfileImagePath -replace '^(.*[\\\/])', ''}
        }

# Get all user SIDs found in HKEY_USERS (ntuder.dat files that are loaded)
$LoadedHives = Get-ChildItem Registry::HKEY_USERS | ? {$_.PSChildname -match $PatternSID} | Select @{name="SID";expression={$_.PSChildName}}
 
# Get all users that are not currently logged
$UnloadedHives = Compare-Object $Profiles.SID $LoadedHives.SID | Select @{name="SID";expression={$_.InputObject}}, UserHive, Username

# Creates a temporary PowerShell drive that provides access to registry
Set-Location Registry::\HKEY_USERS
New-PSDrive HKU Registry HKEY_USERS

# Loop through each profile on the machine
Foreach ($Profile in $Profiles) {

    # Load User ntuser.dat if it's not already loaded
    If ($Profile.SID -in $UnloadedHives.SID) {
    & REG LOAD HKU\$($Profile.SID) $($Profile.UserHive) | Out-Null
    }

    # -- Apply Users Customisations -- 
    ##################################

    # Import Start Menu layout
    If (Test-Path -Path "$($Profile.UserProfilePath)\AppData\Local\Microsoft\Windows\Shell\") {
        $LayoutModification | Out-File "$($Profile.UserProfilePath)\AppData\Local\Microsoft\Windows\Shell\LayoutModification.xml" -Encoding Ascii | Out-Null
        }

    # Reset Start Menu layout
    If (Test-Path HKU:\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount) {
        Remove-Item -Path "HKU:\$($Profile.SID)\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount" -Recurse -Force | Out-Null
        }

    ##################################

    # Unload ntuser.dat        
    If ($Profile.SID -in $UnloadedHives.SID) {
        [gc]::Collect()
        & REG UNLOAD HKU\$($Profile.SID) | Out-Null
        }
    }

# Unload PowerShell drive
Remove-PSDrive HKU