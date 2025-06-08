



# protocol, networkID, siteNumber, "site name"
# P25, BEE00.2D1, 3.15, "Mt Gladstone (GALD)"

Import-Csv -Path $PSScriptRoot\DSDPlus-Sites.csv | `
Where-Object {$_.STATUS -Match 'FUT|ACTV|LVNG'} |  `
Select-Object STKEY, FIRST_NAME, SURNAME, @{Name='E_MAIL';Expression={$_.STKEY.ToLower() + '@corryong.vic.edu.au'}}, GENDER, HOME_GROUP, SCHOOL_YEAR, @{Name='TITLE';Expression={'Student'}} | `
Export-Csv -NoTypeInformation -Append -Path "${env:ProgramFiles(x86)}\DsdPlus\DSDPlu.-Sites"

