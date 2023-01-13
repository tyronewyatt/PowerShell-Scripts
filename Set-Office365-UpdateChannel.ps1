# Update channel below to Current, Monthly Enterprise or Semi-Annual Enterprise.
$Channel = 'Monthly Enterprise'

Write-Host Updating Office 365 Channel to $Channel`.

$UpdateChannel = @()
$UpdateChannel += [PSCustomObject] @{CDNBaseUrl='http://officecdn.microsoft.com/pr/492350f6-3a01-4f97-b9c0-c7c6ddf67d60';Channel='Current'}
$UpdateChannel += [PSCustomObject] @{CDNBaseUrl='http://officecdn.microsoft.com/pr/55336b82-a18d-4dd6-b5f6-9e5095c314a6';Channel='Monthly Enterprise'}
$UpdateChannel += [PSCustomObject] @{CDNBaseUrl='http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114';Channel='Semi-Annual Enterprise'}
$UpdateChannel = $UpdateChannel | Where-Object Channel -Eq $Channel

If ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' | Select-Object -ExpandProperty CDNBaseUrl) -ne $UpdateChannel.CDNBaseUrl) 
    {New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration' -Name CDNBaseUrl -Value $UpdateChannel.CDNBaseUrl -PropertyType String -Force -ea SilentlyContinue}