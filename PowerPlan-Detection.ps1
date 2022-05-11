#Power Scheme Personality
#0 = Power Saver
#1 = High Performance
#2 = Balanced

If ($(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\db310065-829b-4671-9647-2261c00e86ef\245d8541-3943-4422-b025-13a784f679b7 | Select-Object -ExpandProperty ACSettingIndex) -Eq 2 `
-Or $(Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\Power\User\PowerSchemes\db310065-829b-4671-9647-2261c00e86ef\245d8541-3943-4422-b025-13a784f679b7 | Select-Object -ExpandProperty DCSettingIndex) -Eq 2)
    {$True} 
Else
    {$False}