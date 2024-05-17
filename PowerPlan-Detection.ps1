# Customized Peak (ConfigMgr) Power Scheme GUID
$PowerSchemeGUID = 'db310065-829b-4671-9647-2261c00e86ef'

# Power Scheme Personality GUID
$PowerSchemePersonalityGUID = '245d8541-3943-4422-b025-13a784f679b7'

# Power Scheme Personality
$PowerSchemePersonality = @(
    [pscustomobject]@{ID='0';Name='Power Saver'}
    [pscustomobject]@{ID='1';Name='High Performance'}
    [pscustomobject]@{ID='2';Name='Balanced'}
)

If ($(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$PowerSchemeGUID\$PowerSchemePersonalityGUID | Select-Object -ExpandProperty ACSettingIndex) -Eq $PowerSchemePersonality[2].ID `
-And $(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$PowerSchemeGUID\$PowerSchemePersonalityGUID | Select-Object -ExpandProperty DCSettingIndex) -Eq $PowerSchemePersonality[2].ID)
    {$True} 
Else
    {$False}