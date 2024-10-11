Param(
    [String] $CSVProtocol  = 'P25',
    [String] $CSVNetworkID = 'BEE00.2D1',
    [String] $CSVGroup     = '-2',
    [String] $CSVPriority  = '50',
    [string] $CSVOverride  = 'Normal',
    [String] $CSVHits      = '0',
    [string] $CSVTimestamp = '0000/00/00  0:00',
    [string] $DSDPath      = "${env:ProgramFiles(x86)}\DSDPlus",
    [bool] $NoConsole
	)

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'
 
$Networks = @()
$Networks += [PSCustomObject] @{ ID='BEE00.164'; Name='VRN (MMR/RMR)'; }
$Networks += [PSCustomObject] @{ ID='BEE00.2D1'; Name='NSW PSN'; }
$Networks += [PSCustomObject] @{ ID='BEE00.351'; Name='NT ESTN'; }
$Networks += [PSCustomObject] @{ ID='BEE00.3D3'; Name='SA GRN'; }
$Networks += [PSCustomObject] @{ ID='BEE00.658'; Name='Qld QWN'; }
$Networks += [PSCustomObject] @{ ID='BEE00.AF8'; Name='Tas GRN'; }

Function Run-Backup {
    $FileDateTime = Get-Date -Format yyyyMMddTHHmmss
    $BackupPath = "${env:ProgramFiles(x86)}\DSDPlusBackups"
    If (!(Test-Path "$BackupPath")) {
        New-item -Path $BackupPath -Name Radios -ItemType Directory
    }
    Do {
        Try {
            #Copy-Item -Path "$DSDPath\DSDPlus.Radios" -Destination "$BackupPath\Radios\DSDPlus.$FileDateTime.Radios" -Force | Out-Null
            Compress-Archive -LiteralPath "$DSDPath\DSDPlus.Radios" -DestinationPath "$BackupPath\Radios\DSDPlus.$FileDateTime.zip" -CompressionLevel Fastest | Out-Null
            }
        Catch {}
    } Until ($?)
}
If ($NoConsole -eq $true -and @(Get-Process -Name DSDPlus).Count -ge 1) {Run-Backup}
If ($NoConsole -eq $false) {Run-Backup}

Function Set-RadioAlias {
    Do {
        Try {
            $CSVRadios = Get-Content -Path "$DSDPath\DSDPlus.Radios" | 
                Where-Object { $_ -notmatch "^;|^   ;;|^$" } | # Remove comments and empty lines
                ConvertFrom-Csv -Header 'protocol', 'networkID', 'group', 'radio', 'priority', 'override', 'hits', 'timestamp', 'radio alias' | 
                Where-Object { $_.'Radio alias' -eq "" -and $_.'networkID' -in $Networks.ID } # Select radios with missing aliases and with known networks
        } Catch {}
    } Until ($?)

    $Radios = @()
    $Radios += [PSCustomObject] @{ ID='100####'; Alias='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='101####'; Alias='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='103####'; Alias='ACT Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='104####'; Alias='ACT'; }    
    $Radios += [PSCustomObject] @{ ID='1050###'; Alias='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='1051###'; Alias='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='1053###'; Alias='ACT Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='20####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='21####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='22####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='23####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='27####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='41####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='42####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='43####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='70####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='200####'; Alias='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='201####'; Alias='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='202####'; Alias='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='203####'; Alias='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='204####'; Alias='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='205####'; Alias='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='206####'; Alias='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='207####'; Alias='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='210####'; Alias='Unknown'; }
    $Radios += [PSCustomObject] @{ ID='211####'; Alias="NSW Sheriff's Office"; }
    $Radios += [PSCustomObject] @{ ID='212####'; Alias='Corrective Services NSW'; }
    $Radios += [PSCustomObject] @{ ID='2130###'; Alias='Youth Justice NSW'; }
    $Radios += [PSCustomObject] @{ ID='214####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='215####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='216####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='217####'; Alias='Unknown'; }
    $Radios += [PSCustomObject] @{ ID='218####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='219####'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='2240###'; Alias='Hunter Water'; }
    $Radios += [PSCustomObject] @{ ID='230####'; Alias='Australian Rail Track Corporation'; }
    $Radios += [PSCustomObject] @{ ID='231####'; Alias='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='232####'; Alias='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='233####'; Alias='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='235####'; Alias='Transport for NSW - Ferries'; }
    $Radios += [PSCustomObject] @{ ID='23600##'; Alias='Transport for NSW'; }
    $Radios += [PSCustomObject] @{ ID='23790##'; Alias='New born & pædiatric Emergency Transport Service'; }
    $Radios += [PSCustomObject] @{ ID='2379###'; Alias='Northern NSW Local Health District'; }
    $Radios += [PSCustomObject] @{ ID='237####'; Alias='NSW Trains'; }
    $Radios += [PSCustomObject] @{ ID='238####'; Alias='Transport for NSW - Roads'; }
    $Radios += [PSCustomObject] @{ ID='242####'; Alias='NSW National Parks & Wildlife Service'; }
    $Radios += [PSCustomObject] @{ ID='243####'; Alias='Transport for NSW - Maritime'; }
    $Radios += [PSCustomObject] @{ ID='245####'; Alias='Water NSW'; }
    $Radios += [PSCustomObject] @{ ID='2448###'; Alias='NSW Department of Primary Industries'; }
    $Radios += [PSCustomObject] @{ ID='2449###'; Alias='NSW Environmental Protection Agency'; }
    $Radios += [PSCustomObject] @{ ID='248####'; Alias='Forestry Corporation of NSW'; }
    $Radios += [PSCustomObject] @{ ID='2500###'; Alias='NSW Police Force - Special Constables'; }
    $Radios += [PSCustomObject] @{ ID='26000##'; Alias='Australian Broadcasting Corporation'; }
    $Radios += [PSCustomObject] @{ ID='26990##'; Alias='RSPCA NSW'; }
    $Radios += [PSCustomObject] @{ ID='2800###'; Alias='Surf Life Saving NSW'; }
    $Radios += [PSCustomObject] @{ ID='290####'; Alias='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='291####'; Alias='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='292####'; Alias='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='4######'; Alias='Qld GWN'; }
    $Radios += [PSCustomObject] @{ ID='310###'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='311###'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='315###'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='320###'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='380###'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='300####'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='320####'; Alias='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='321####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='311####'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='314####'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='316####'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='317####'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='322####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='323####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='324####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='325####'; Alias='Fire Rescue Victoria'; }
    $Radios += [PSCustomObject] @{ ID='326####'; Alias='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='327####'; Alias='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='328####'; Alias='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='330####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='331####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='333####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='338####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='339####'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='344####'; Alias='Life Saving Victoria'; }
    $Radios += [PSCustomObject] @{ ID='902####'; Alias='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='913####'; Alias='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='925####'; Alias='Australian Federal Police'; }
    #$Radios += [PSCustomObject] @{ ID='338####'; Alias='Unknown'; }

    ForEach ($Radio in $Radios) {
        $NetworkIDs = $Networks.ID
        $RadioAlias = $Radio.Alias
        $RadioID = '^' + $Radio.ID.Replace('#','\d') + '$'  # Replace hash with digit

        ForEach ($CSVRadio in $CSVRadios) {
            $Protocol = $CSVRadio.protocol
            $NetworkID = $CSVRadio.networkID
            $Radio = $CSVRadio.radio
            $Group = $CSVRadio.group
            $Priority = $CSVRadio.priority
            $Override = $CSVRadio.override
            $Hits = $CSVRadio.hits
            $Timestamp = $CSVRadio.timestamp
            If (
                ($Radio -match $RadioID) -and 
                ($NetworkID -in $NetworkIDs)
                ) {
                If ($NoConsole -eq $false) {
                    Write-Host "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$RadioAlias`""
                }
                Do {
                    Try {Write-Output "$Protocol, $NetworkID, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$RadioAlias`"" |
                        Out-File -Append "$DSDPath\DSDPlus.Radios" -Encoding utf8 -NoClobber
                    } Catch {}
                } Until ($?)
            }
        }
    }
}
If ($NoConsole -eq $true -and @(Get-Process -Name DSDPlus).Count -ge 1) {Set-RadioAlias}
If ($NoConsole -eq $false) {Set-RadioAlias}


Function Export-Radios {

    Do {
        Try {
        Get-Content -Path "$DSDPath\DSDPlus.Radios" | 
            Where-Object { $_ -notmatch "^;|^   ;;|^$" } | 
            ConvertFrom-Csv -Header 'Protocol', 'NetworkID', 'Group', 'Radio', 'priority', 'Override', 'Hits', 'Timestamp', 'Radio alias' |
            Export-Csv  "$PSScriptRoot\Radios.csv" -NoTypeInformation
        } Catch {}
    } Until ($?)
}
#Export-Radios

Function Import-Radios {

    $CsvRadios = Import-Csv -Path "$PSScriptRoot\Radios2.csv"

    ForEach ($CsvRadio in $CsvRadios) {
        $CSVNetworkID = $CsvRadio.NetworkID
        $CSVRadio = $CsvRadio.Radio
        $CSVGroup = $CsvRadio.Group
        $CSVPriority = $CsvRadio.priority
        $CSVOverride = $CsvRadio.Override
        $CSVHits = $CsvRadio.Hits
        $CSVTimestamp = $CsvRadio.Timestamp
        $CSVRadioalias = $CsvRadio.'Radio alias'

        Write-Host "$CSVProtocol, $CSVNetworkID, $CSVGroup, $CSVRadio, $CSVPriority, $CSVOverride, $CSVHits, $CSVTimestamp, `"$CSVRadioalias`""
        Do {
            Try {
            Write-Output "$CSVProtocol, $CSVNetworkID, $CSVGroup, $CSVRadio, $CSVPriority, $CSVOverride, $CSVHits, $CSVTimestamp, `"$CSVRadioalias`"" | 
                Out-File -Append "$DSDPath\DSDPlus.Radios" -Encoding utf8 -NoClobber
            } Catch {}
        } Until ($?)
    }
}
#Import-Radios