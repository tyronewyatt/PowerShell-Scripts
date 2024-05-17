﻿Param(
	[String]$Protocol = 'P25',
	[String]$NetworkID = 'BEE00.2D1',
	[String]$Group = '-2',
    [string]$Priority = '50',
    [string]$Override = 'Normal',
    [string]$Hits = '0',
    [string]$Timestamp = '0000/00/00  0:00',
    [string]$Path = "${env:ProgramFiles(x86)}\DSDPlus"
	)

Function Set-RadioAlias {

    $DSDPlusRadios = Get-Content -Path "$Path\DSDPlus.Radios" | 
        Where-Object { $_ -notmatch "^;|^   ;;|^$" } | 
        ConvertFrom-Csv -Header 'protocol', 'networkID', 'group', 'radio', 'priority', 'override', 'hits', 'timestamp', 'radio alias' | 
        Where-Object { $_.'radio alias' -eq "" } 

    $Agencies = @()
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='20####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='21####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='42####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='43####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='70####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='200####'; Name='Fire and Rescue NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='201####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='202####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='203####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='204####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='205####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='206####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='207####'; Name='Fire and Rescue NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='211####'; Name="NSW Sheriff's Office"; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='212####'; Name='Corrective Services NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2130###'; Name='Youth Justice NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='230####'; Name='Australian Rail Track Corporation'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='231####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='232####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='233####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='238####'; Name='Transport for NSW - Roads'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='242####'; Name='NSW National Parks & Wildlife Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='243####'; Name='Transport for NSW - Maritime'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2448###'; Name='NSW Department of Primary Industries'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2449###'; Name='NSW Environmental Protection Agency'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='248####'; Name='Forestry Corporation of NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2500###'; Name='NSW Police Force - Special Constables'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='26990##'; Name='RSPCA NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2800###'; Name='Surf Life Saving NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='290####'; Name='NSW Telco Authority - Rental'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='291####'; Name='NSW Telco Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='292####'; Name='P25 ISSI'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='320###'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='311####'; Name='Victoria Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='323####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='324####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='325####'; Name='Fire Rescue Victoria'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='326####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='327####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='328####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='330####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='333####'; Name='Country Fire Authority'; }
    #$Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='338####'; Name='Unknown'; }

    ForEach ($Agency in $Agencies) {
        $AgencyNetworkID = $Agency.NetworkID
        $AgencyName = $Agency.Name
        $AgencyRadio = '^' + $Agency.Radio.Replace('#','\d') + '$'  

        ForEach ($DSDPlusRadio in $DSDPlusRadios) {
            $NetworkID = $DSDPlusRadio.networkID
            $Radio = $DSDPlusRadio.radio
            $Group = $DSDPlusRadio.group
            $Priority = $DSDPlusRadio.priority
            $Override = $DSDPlusRadio.override
            $Hits = $DSDPlusRadio.hits
            $Timestamp = $DSDPlusRadio.timestamp
            If (
                ($Radio -match $AgencyRadio) -and 
                ($NetworkID -match $AgencyNetworkID)
                ) {
                Write-Host "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$AgencyName`""
                Write-Output "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$AgencyName`"" | 
                    Out-File -Append "$Path\DSDPlus.Radios" -Encoding utf8 -NoClobber
            }
        }
    }
}

Set-RadioAlias

Function Export-Radios {

    Get-Content -Path "$Path\DSDPlus.Radios" | 
        Where-Object { $_ -notmatch "^;|^   ;;|^$" } | 
        ConvertFrom-Csv -Header 'protocol', 'networkID', 'group', 'radio', 'priority', 'override', 'hits', 'timestamp', 'radio alias' |
        Export-Csv  "$PSScriptRoot\Radios.csv" -NoTypeInformation
}


Function Import-Radios {

    $CsvRadios = Import-Csv -Path "$PSScriptRoot\Radios.csv"

    ForEach ($CsvRadio in $CsvRadios) {
        $NetworkID = $CsvRadio.networkID
        $Radio = $CsvRadio.radio
        $Group = $CsvRadio.group
        $Priority = $CsvRadio.priority
        $Override = $CsvRadio.override
        $Hits = $CsvRadio.hits
        $Timestamp = $CsvRadio.timestamp
        $Radioalias = $CsvRadio.'Radio alias'

        Write-Host "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$Radioalias`""
        Write-Output "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$Radioalias`"" | 
        Out-File -Append "$Path\DSDPlus.Radios" -Encoding utf8 -NoClobber
    }
}