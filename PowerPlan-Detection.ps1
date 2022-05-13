# Power Scheme Personality
$SchemePersonality = @(
    [pscustomobject]@{Name='Power Saver';      ID='0'}
    [pscustomobject]@{Name='High Performance'; ID='1'}
    [pscustomobject]@{Name='Balanced';         ID='2'}
)

# Customized Peak (ConfigMgr) Power Scheme
$PowerScheme = 'db310065-829b-4671-9647-2261c00e86ef'

If ($(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$PowerScheme\245d8541-3943-4422-b025-13a784f679b7 | Select-Object -ExpandProperty ACSettingIndex) -Eq $SchemePersonality[2].ID `
-And $(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\$PowerScheme\245d8541-3943-4422-b025-13a784f679b7 | Select-Object -ExpandProperty DCSettingIndex) -Eq $SchemePersonality[2].ID)
    {$True} 
Else
    {$False}