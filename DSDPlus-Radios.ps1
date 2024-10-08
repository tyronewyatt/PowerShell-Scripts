﻿Param(
    [String] $Protocol  = 'P25',
    [String] $NetworkID = 'BEE00.2D1',
    [String] $Group     = '-2',
    [String] $priority  = '50',
    [string] $Override  = 'Normal',
    [String] $Hits      = '0',
    [string] $Timestamp = '0000/00/00  0:00',
    [string] $Path      = "${env:ProgramFiles(x86)}\DSDPlus"
	)

Function Run-Backup {
    $FileDateTime = Get-Date -Format yyyyMMddTHHmmss
    If (!(Test-Path "$Path\Backup")) {
        New-item -Path $Path -Name Backup -ItemType Directory
    }
    Copy-Item -Path "$Path\DSDPlus.Radios" -Destination "$Path\Backup\DSDPlus.$FileDateTime.Radios" -Force | Out-Null
}
Run-Backup

Function Set-RadioAlias {
    Do {
        Try {
            $DSDPlusRadios = Get-Content -Path "$Path\DSDPlus.Radios" -ErrorAction SilentlyContinue | 
                Where-Object { $_ -notmatch "^;|^   ;;|^$" } | # Remove comments and empty lines
                ConvertFrom-Csv -Header 'protocol', 'networkID', 'group', 'radio', 'priority', 'override', 'hits', 'timestamp', 'radio alias' | 
                Where-Object { $_.'Radio alias' -eq "" } # Select missing radio aliases
        } Catch {}
    } Until ($?)

    $Agencies = @()
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='100####'; Name='ACT Ambulance Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='101####'; Name='ACT Fire & Rescue'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='103####'; Name='ACT Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='104####'; Name='ACT'; }    
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='1050###'; Name='ACT Ambulance Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='1051###'; Name='ACT Fire & Rescue'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='1053###'; Name='ACT Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='20####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='21####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='22####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='23####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='41####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='42####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='43####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='70####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='200####'; Name='Fire & Rescue NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='201####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='202####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='203####'; Name='NSW Rural Fire Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='204####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='205####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='206####'; Name='NSW State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='207####'; Name='Fire & Rescue NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='210####'; Name='Unknown'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='211####'; Name="NSW Sheriff's Office"; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='212####'; Name='Corrective Services NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2130###'; Name='Youth Justice NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='214####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='215####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='216####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='217####'; Name='Unknown'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='218####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='219####'; Name='NSW Police Force'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2240###'; Name='Hunter Water'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='230####'; Name='Australian Rail Track Corporation'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='231####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='232####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='233####'; Name='NSW Ambulance'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='235####'; Name='Transport for NSW - Ferries'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='23790##'; Name='New born & pædiatric Emergency Transport Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2379###'; Name='Northern NSW Local Health District'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='237####'; Name='NSW Trains'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='238####'; Name='Transport for NSW - Roads'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='242####'; Name='NSW National Parks & Wildlife Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='243####'; Name='Transport for NSW - Maritime'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='245####'; Name='Water NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2448###'; Name='NSW Department of Primary Industries'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2449###'; Name='NSW Environmental Protection Agency'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='248####'; Name='Forestry Corporation of NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2500###'; Name='NSW Police Force - Special Constables'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='26000##'; Name='Australian Broadcasting Corporation'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='26990##'; Name='RSPCA NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='2800###'; Name='Surf Life Saving NSW'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='290####'; Name='NSW Telco Authority - Network Manager'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='291####'; Name='NSW Telco Authority - Network Manager'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='292####'; Name='NSW Telco Authority - Network Manager'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='4######'; Name='Qld GWN'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='902####'; Name='Australian Federal Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='913####'; Name='Australian Federal Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.2D1'; Radio='925####'; Name='Australian Federal Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='311###'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='315###'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='320###'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='380###'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='300####'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='320####'; Name='Emergency Services Telecommunications Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='321####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='311####'; Name='Victoria Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='314####'; Name='Victoria Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='316####'; Name='Victoria Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='317####'; Name='Victoria Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='322####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='323####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='324####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='325####'; Name='Fire Rescue Victoria'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='326####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='327####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='328####'; Name='Victoria State Emergency Service'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='330####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='331####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='333####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='338####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='339####'; Name='Country Fire Authority'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='344####'; Name='Life Saving Victoria'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='902####'; Name='Australian Federal Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='913####'; Name='Australian Federal Police'; }
    $Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='925####'; Name='Australian Federal Police'; }
    #$Agencies += [PSCustomObject] @{ NetworkID='BEE00.164'; Radio='338####'; Name='Unknown'; }

    ForEach ($Agency in $Agencies) {
        $AgencyNetworkID = $Agency.NetworkID
        $AgencyName = $Agency.Name
        $AgencyRadio = '^' + $Agency.Radio.Replace('#','\d') + '$'  # Replace hash with digit

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
                Do {
                    Try {Write-Output "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$AgencyName`"" |
                        Out-File -Append "$Path\DSDPlus.Radios" -Encoding utf8 -NoClobber -ErrorAction SilentlyContinue
                    } Catch {}
                } Until ($?)
            }
        }
    }
}
Set-RadioAlias

Function Export-Radios {

    Do {
        Try {
        Get-Content -Path "$Path\DSDPlus.Radios" -ErrorAction SilentlyContinue | 
            Where-Object { $_ -notmatch "^;|^   ;;|^$" } | 
            ConvertFrom-Csv -Header 'Protocol', 'NetworkID', 'Group', 'Radio', 'priority', 'Override', 'Hits', 'Timestamp', 'Radio alias' |
            Export-Csv  "$PSScriptRoot\Radios.csv" -NoTypeInformation
        } Catch {}
    } Until ($?)
}


Function Import-Radios {

    $CsvRadios = Import-Csv -Path "$PSScriptRoot\Radios.csv"

    ForEach ($CsvRadio in $CsvRadios) {
        $NetworkID = $CsvRadio.NetworkID
        $Radio = $CsvRadio.Radio
        $Group = $CsvRadio.Group
        $priority = $CsvRadio.priority
        $Override = $CsvRadio.Override
        $Hits = $CsvRadio.Hits
        $Timestamp = $CsvRadio.Timestamp
        $Radioalias = $CsvRadio.'Radio alias'

        Do {
            $SaveCount++
            Write-Host "$Protocol, $NetworkID, $Group, $Radio, $priority, $Override, $Hits, $Timestamp, `"$Radioalias`""
            Try {
            Write-Output "$Protocol, $NetworkID, $Group, $Radio, $priority, $Override, $Hits, $Timestamp, `"$Radioalias`"" | 
                Out-File -Append "$Path\DSDPlus.Radios" -Encoding utf8 -NoClobber -ErrorAction SilentlyContinue
            } Catch {}
        } Until ($?)
    }
}
#Import-Radios