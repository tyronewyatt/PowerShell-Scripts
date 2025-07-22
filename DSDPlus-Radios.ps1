Param(
    [String] $CSVProtocol  = 'P25',
    [String] $CSVNetworkID = 'BEE00.2D1',
    [String] $CSVGroup     = '-2',
    [String] $CSVPriority  = '50',
    [string] $CSVOverride  = 'Normal',
    [String] $CSVHits      = '0',
    [string] $CSVTimestamp = '0000/00/00  0:00',
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
    Param (
        [string] $DSDPath,
        [string] $BackupPath,
        [string] $FileDateTime = @(Get-Date -Format yyyyMMddTHHmmss)
    )
    If (!(Test-Path "$BackupPath")) {
        New-item -Path $BackupPath -Name Radios -ItemType Directory
    }
    Do {
        Try {
            Compress-Archive -LiteralPath "$DSDPath\DSDPlus.Radios" -DestinationPath "$BackupPath\Radios\DSDPlus.$FileDateTime.zip" -CompressionLevel Fastest
            If ($?) {Write-Host "$DSDPath\DSDPlus.Radios > $BackupPath\Radios\DSDPlus.$FileDateTime.zip"}
            Start-Sleep -Seconds 1
            }
        Catch {}
    } Until ($?)

}
Write-Host "== RUN BACKUP =="
Run-Backup -DSDPath "${env:ProgramFiles(x86)}\DSDPlus" -BackupPath "${env:ProgramFiles(x86)}\DSDPlusBackups"
Run-Backup -DSDPath "${env:ProgramFiles(x86)}\DSDPlus-VRN" -BackupPath "${env:ProgramFiles(x86)}\DSDPlusBackups"

Function Set-RadioAlias {
    Param (
        [string] $DSDPath
    )
    Do {
        Try {
            $CSVRadios = Get-Content -Path "$DSDPath\DSDPlus.Radios" | 
                Where-Object { $_ -notmatch "^;|^   ;;|^$" } | # Remove comments and empty lines
                ConvertFrom-Csv -Header 'protocol', 'networkID', 'group', 'radio', 'priority', 'override', 'hits', 'timestamp', 'radio alias', 'callsign' | 
                Where-Object { $_.'Radio alias' -eq "" -and $_.'networkID' -in $Networks.ID } # Select radios with missing aliases and with known networks
        } Catch {}
    } Until ($?)

    $Radios = @()
#    $Radios += [PSCustomObject] @{ ID=''; Alias=''; }
    $Radios += [PSCustomObject] @{ ID='1000000-1009999'; Alias='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='1010000-1019999'; Alias='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='1030000-1039999'; Alias='ACT Rural Fire Service'; } 
    $Radios += [PSCustomObject] @{ ID='1050000-1050999'; Alias='ACT Ambulance Service'; }
    $Radios += [PSCustomObject] @{ ID='1051000-1051999'; Alias='ACT Fire & Rescue'; }
    $Radios += [PSCustomObject] @{ ID='1052000-1052999'; Alias='ACT State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='1053000-1053999'; Alias='ACT Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='2000000-2000099'; Alias='Fire & Rescue NSW - Sydney Communication Centre'; }
    $Radios += [PSCustomObject] @{ ID='2000100-2000199'; Alias='Fire & Rescue NSW - Newcastle Communication Centre'; }
    $Radios += [PSCustomObject] @{ ID='2000200-2009999'; Alias='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='2010000-2019899'; Alias='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='2019900-2019999'; Alias='NSW Rural Fire Service - Operational Communications Centre'; }
    $Radios += [PSCustomObject] @{ ID='2020000-2039999'; Alias='NSW Rural Fire Service'; }
    $Radios += [PSCustomObject] @{ ID='2040000-2069899'; Alias='NSW State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='2069900-2069999'; Alias='NSW State Emergency Service - State Operations Centre'; }
    $Radios += [PSCustomObject] @{ ID='2070000-2079999'; Alias='Fire & Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='2110000-2119999'; Alias="NSW Sheriff's Office"; }
    $Radios += [PSCustomObject] @{ ID='2120000-2129999'; Alias='Corrective Services NSW'; }
    $Radios += [PSCustomObject] @{ ID='2130000-2130999'; Alias='Youth Justice NSW'; }
    $Radios += [PSCustomObject] @{ ID='2140000-2169999'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='2177000-2177999'; Alias='NSW Crime Commission'; }
    $Radios += [PSCustomObject] @{ ID='2180000-2199999'; Alias='NSW Police Force'; }
    $Radios += [PSCustomObject] @{ ID='2200000-2200999'; Alias='Central Tablelands Water'; }
    $Radios += [PSCustomObject] @{ ID='2220000-2221999'; Alias='Ausgrid'; }
    $Radios += [PSCustomObject] @{ ID='2230000-2230999'; Alias='Integral Energy'; }
    $Radios += [PSCustomObject] @{ ID='2240000-2240999'; Alias='Hunter Water'; }
    $Radios += [PSCustomObject] @{ ID='2300000-2300599'; Alias='Australian Rail Track Corporation'; }
    $Radios += [PSCustomObject] @{ ID='2310000-2339999'; Alias='NSW Ambulance'; }
    $Radios += [PSCustomObject] @{ ID='2350000-2359999'; Alias='Transport for NSW - Roads & Waterways'; }
    $Radios += [PSCustomObject] @{ ID='2360099-2360099'; Alias='Transport for NSW'; }
    $Radios += [PSCustomObject] @{ ID='2379000-2379099'; Alias='New born & pædiatric Emergency Transport Service'; }
    $Radios += [PSCustomObject] @{ ID='2379100-2379999'; Alias='Northern NSW Local Health District'; }
    $Radios += [PSCustomObject] @{ ID='2370000-2379999'; Alias='NSW Trains'; }
    $Radios += [PSCustomObject] @{ ID='2380000-2389999'; Alias='Transport for NSW - Roads & Waterways'; }
    $Radios += [PSCustomObject] @{ ID='2420000-2429999'; Alias='NSW National Parks & Wildlife Service'; }
    $Radios += [PSCustomObject] @{ ID='2430000-2439999'; Alias='Transport for NSW - Roads & Waterways'; }
    $Radios += [PSCustomObject] @{ ID='2450000-2450999'; Alias='Water NSW'; }
    $Radios += [PSCustomObject] @{ ID='2442000-2442999'; Alias='NSW Department of Primary Industries - Plantation Forestry'; }
    $Radios += [PSCustomObject] @{ ID='2448000-2448999'; Alias='NSW Department of Primary Industries - Fisheries'; }
    $Radios += [PSCustomObject] @{ ID='2449000-2449999'; Alias='Marine Rescue NSW'; }
    $Radios += [PSCustomObject] @{ ID='2480000-2489999'; Alias='Forestry Corporation of NSW'; }
    $Radios += [PSCustomObject] @{ ID='2500000-2500999'; Alias='NSW Police Force - Special Constables'; }
    $Radios += [PSCustomObject] @{ ID='2576500-2576599'; Alias='ACEREZ Central-West Orana Renewable Energy Zone'; }
    $Radios += [PSCustomObject] @{ ID='2600000-2600099'; Alias='Australian Broadcasting Corporation'; }
    $Radios += [PSCustomObject] @{ ID='2629600-2629699'; Alias='Blue Mountains City Council'; }
    $Radios += [PSCustomObject] @{ ID='2650000-2650999'; Alias='Sydney Opera House'; }
    $Radios += [PSCustomObject] @{ ID='2665000-2665999'; Alias='St John Ambulance NSW'; }
    $Radios += [PSCustomObject] @{ ID='2699000-2699099'; Alias='RSPCA NSW'; }
    $Radios += [PSCustomObject] @{ ID='2800000-2800999'; Alias='Surf Life Saving NSW'; }
    $Radios += [PSCustomObject] @{ ID='2900000-2929999'; Alias='NSW Telco Authority - Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='310000-310999'; Alias='Triple Zero Victoria'; }
    $Radios += [PSCustomObject] @{ ID='311000-311999'; Alias='Triple Zero Victoria'; }
    $Radios += [PSCustomObject] @{ ID='315000-315999'; Alias='Triple Zero Victoria'; }
    $Radios += [PSCustomObject] @{ ID='320000-320999'; Alias='Triple Zero Victoria'; }
    $Radios += [PSCustomObject] @{ ID='380000-280999'; Alias='Triple Zero Victoria'; }
    $Radios += [PSCustomObject] @{ ID='3000000-3009999'; Alias='Motorola Network Manager'; }
    $Radios += [PSCustomObject] @{ ID='3200000-3219999'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='3110000-3119999'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='3140000-3149999'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='3160000-3179999'; Alias='Victoria Police'; }
    $Radios += [PSCustomObject] @{ ID='3220000-3259999'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='3260000-3289999'; Alias='Victoria State Emergency Service'; }
    $Radios += [PSCustomObject] @{ ID='3290000-3339999'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='3380000-3399999'; Alias='Country Fire Authority'; }
    $Radios += [PSCustomObject] @{ ID='3440000-3449999'; Alias='Life Saving Victoria'; }
    $Radios += [PSCustomObject] @{ ID='4300000-4309999'; Alias='Queensland Police Service'; }
    $Radios += [PSCustomObject] @{ ID='4360000-4369999'; Alias='Queensland State Emergency Service'; }
#    $Radios += [PSCustomObject] @{ ID='4000000-4999999'; Alias='Qld GWN'; }
#    $Radios += [PSCustomObject] @{ ID='5000000-5999999'; Alias='SA GRN'; }
#    $Radios += [PSCustomObject] @{ ID='6000000-6999999'; Alias='WA GRN'; }
#    $Radios += [PSCustomObject] @{ ID='7000000-7999999'; Alias='Tas GRN'; }
#    $Radios += [PSCustomObject] @{ ID='8000000-8999999'; Alias='NT ESTN'; }
    $Radios += [PSCustomObject] @{ ID='9020000-9039999'; Alias='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='9130000-9139999'; Alias='Australian Federal Police'; }
    $Radios += [PSCustomObject] @{ ID='9250000-9259999'; Alias='Australian Federal Police'; }

    ForEach ($Radio in $Radios) {
        $NIDs = $Networks.ID
        $Agency = $Radio.Alias
        #$RadioID = '^' + $Radio.ID.Replace('#','\d') + '$'  # Replace hash with digit
        $RIDs = $Radio.ID -split '-'

        ForEach ($CSVRadio in $CSVRadios) {
            $Protocol = $CSVRadio.protocol
            $Network = $CSVRadio.networkID
            $Radio = $CSVRadio.radio
            $Group = $CSVRadio.group
            $Priority = $CSVRadio.priority
            $Override = $CSVRadio.override
            $Hits = $CSVRadio.hits
            $Timestamp = $CSVRadio.timestamp
            $Callsign = $CSVRadio.callsign
            If (
                (($Radio -gt $RIDs[0]) -and ($Radio -lt $RIDs[1])) -and
                (($Radio.ToString().Length -eq $RIDs[0].ToString().Length) -and ($Radio.ToString().Length -eq $RIDs[1].ToString().Length))
                ) {
                If ($NoConsole -eq $false) {
                    Write-Host "$Protocol, $Network, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$Agency`"" "> $DSDPath\DSDPlus.Radios"
                }
                Do {
                    Try {Write-Output "$Protocol, $Network, $Group, $Radio, $Priority, $Override, $Hits, $Timestamp, `"$Agency`"" |
                        Out-File -Append "$DSDPath\DSDPlus.Radios" -Encoding utf8 -NoClobber
                    } Catch {}
                } Until ($?)
            }
        }
    }
}
Write-Host "== SET RADIO ALIAS =="
Set-RadioAlias -DSDPath "${env:ProgramFiles(x86)}\DSDPlus"
Set-RadioAlias -DSDPath "${env:ProgramFiles(x86)}\DSDPlus-VRN"

Function Export-Radios {
    Param (
        [string] $DSDPath
    )
    Do {
        Try {
        Get-Content -Path "$DSDPath\DSDPlus.Radios" | 
            Where-Object { $_ -notmatch "^;|^   ;;|^$" } | 
            ConvertFrom-Csv -Header 'Protocol', 'NetworkID', 'Group', 'Radio', 'priority', 'Override', 'Hits', 'Timestamp', 'Radio alias' |
            Export-Csv  "$PSScriptRoot\Radios.csv" -NoTypeInformation
        } Catch {}
    } Until ($?)
}
#Export-Radios -DSDPath "${env:ProgramFiles(x86)}\DSDPlus"

Function Import-Radios {
    Param (
        [string] $DSDPath,
        [string] $RadioImport = "$PSScriptRoot\Radios.csv"
    )

    $CsvRadios = Import-Csv -Path $RadioImport

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
#Import-Radios -DSDPath "${env:ProgramFiles(x86)}\DSDPlus" -RadioImport ".\Radios.csv"