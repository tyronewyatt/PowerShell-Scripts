Param(
    [String] $CSVProtocol  = 'P25',
    [String] $CSVNetworkID = 'BEE00.2D1',
    [String] $CSVGroup     = '-2',
    [String] $CSVPriority  = '50',
    [string] $CSVOverride  = 'Normal',
    [String] $CSVHits      = '0',
    [string] $CSVTimestamp = '0000/00/00  0:00',
    [string] $Path      = "${env:ProgramFiles(x86)}\DSDPlus"
	)

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
    Copy-Item -Path "$Path\DSDPlus.Radios" -Destination "$BackupPath\Radios\DSDPlus.$FileDateTime.Radios" -Force | Out-Null
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

    $Radios = @()
    $Radios += [PSCustomObject] @{ ID='100####'; Name='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='101####'; Name='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='103####'; Name='ACT Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='104####'; Name='ACT'; }    
    $Radios += [PSCustomObject] @{ ID='1050###'; Name='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='1051###'; Name='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='1053###'; Name='ACT Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='20####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='21####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='22####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='23####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='41####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='42####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='43####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='70####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='200####'; Name='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='201####'; Name='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='202####'; Name='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='203####'; Name='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='204####'; Name='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='205####'; Name='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='206####'; Name='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='207####'; Name='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='210####'; Name='Unknown'; }
    $Radios += [PSCustomObject] @{ ID='211####'; Name="NSW Sheriff's Office"; }
    $Radios += [PSCustomObject] @{ ID='212####'; Name='Corrective Services NSW'; }
    $Radios += [PSCustomObject] @{ ID='2130###'; Name='Youth Justice NSW'; }
    $Radios += [PSCustomObject] @{ ID='214####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='215####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='216####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='217####'; Name='Unknown'; }
    $Radios += [PSCustomObject] @{ ID='218####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='219####'; Name='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='2240###'; Name='Hunter Water'; }
    $Radios += [PSCustomObject] @{ ID='230####'; Name='Australian Rail Track Corporation'; }
    $Radios += [PSCustomObject] @{ ID='231####'; Name='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='232####'; Name='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='233####'; Name='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='235####'; Name='Transport for NSW - Ferries'; }
    $Radios += [PSCustomObject] @{ ID='23600##'; Name='Transport for NSW'; }
    $Radios += [PSCustomObject] @{ ID='23790##'; Name='New born & pædiatric Emergency Transport Service'; }
    $Radios += [PSCustomObject] @{ ID='2379###'; Name='Northern NSW Local Health District'; }
    $Radios += [PSCustomObject] @{ ID='237####'; Name='NSW Trains'; }
    $Radios += [PSCustomObject] @{ ID='238####'; Name='Transport for NSW - Roads'; }
    $Radios += [PSCustomObject] @{ ID='242####'; Name='NSW National Parks & Wildlife Service'; }
    $Radios += [PSCustomObject] @{ ID='243####'; Name='Transport for NSW - Maritime'; }
    $Radios += [PSCustomObject] @{ ID='245####'; Name='Water NSW'; }
    $Radios += [PSCustomObject] @{ ID='2448###'; Name='NSW Department of Primary Industries'; }
    $Radios += [PSCustomObject] @{ ID='2449###'; Name='NSW Environmental Protection Agency'; }
    $Radios += [PSCustomObject] @{ ID='248####'; Name='Forestry Corporation of NSW'; }
    $Radios += [PSCustomObject] @{ ID='2500###'; Name='NSW Police Force - Special Constables'; }
    $Radios += [PSCustomObject] @{ ID='26000##'; Name='Australian Broadcasting Corporation'; }
    $Radios += [PSCustomObject] @{ ID='26990##'; Name='RSPCA NSW'; }
    $Radios += [PSCustomObject] @{ ID='2800###'; Name='Surf Life Saving NSW'; }
    $Radios += [PSCustomObject] @{ ID='290####'; Name='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='291####'; Name='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='292####'; Name='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='4######'; Name='Qld GWN'; }
    $Radios += [PSCustomObject] @{ ID='310###'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='311###'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='315###'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='320###'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='380###'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='300####'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='320####'; Name='Emergency Services Telecommunications Authority'; }
    $Radios += [PSCustomObject] @{ ID='321####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='311####'; Name='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='314####'; Name='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='316####'; Name='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='317####'; Name='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='322####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='323####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='324####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='325####'; Name='Fire Rescue Victoria'; }
    $Radios += [PSCustomObject] @{ ID='326####'; Name='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='327####'; Name='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='328####'; Name='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='330####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='331####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='333####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='338####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='339####'; Name='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='344####'; Name='Life Saving Victoria'; }
    $Radios += [PSCustomObject] @{ ID='902####'; Name='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='913####'; Name='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='925####'; Name='Australian Federal Police'; }
    #$Radios += [PSCustomObject] @{ ID='338####'; Name='Unknown'; }

    ForEach ($Radio in $Radios) {
        $NetworkIDs = $Networks.ID
        $RadioName = $Radio.Name
        $RadioID = '^' + $Radio.ID.Replace('#','\d') + '$'  # Replace hash with digit

        ForEach ($DSDPlusRadio in $DSDPlusRadios) {
            $CSVProtocol = $DSDPlusRadio.protocol
            $CSVNetworkID = $DSDPlusRadio.networkID
            $CSVRadio = $DSDPlusRadio.radio
            $CSVGroup = $DSDPlusRadio.group
            $CSVPriority = $DSDPlusRadio.priority
            $CSVOverride = $DSDPlusRadio.override
            $CSVHits = $DSDPlusRadio.hits
            $CSVTimestamp = $DSDPlusRadio.timestamp
            If (
                ($CSVRadio -match $RadioID) -and 
                ($CSVNetworkID -in $NetworkIDs)
                ) {
                Write-Host "$CSVProtocol, $CSVNetworkID, $CSVGroup, $CSVRadio, $CSVPriority, $CSVOverride, $CSVHits, $CSVTimestamp, `"$RadioName`""
                Do {
                    Try {Write-Output "$CSVProtocol, $CSVNetworkID, $CSVGroup, $CSVRadio, $CSVPriority, $CSVOverride, $CSVHits, $CSVTimestamp, `"$RadioName`"" |
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
                Out-File -Append "$Path\DSDPlus.Radios" -Encoding utf8 -NoClobber -ErrorAction SilentlyContinue
            } Catch {}
        } Until ($?)
    }
}
#Import-Radios