# Update Channels
$UpdateChannels = @()
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Current';
                                        KeyValue = 'Current';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Current (Preview)';
                                        KeyValue = 'FirstReleaseCurrent';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Monthly Enterprise';
                                        KeyValue = 'MonthlyEnterprise';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Semi-Annual Enterprise';
                                        KeyValue = 'Deferred';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Semi-Annual Enterprise (Preview)';
                                        KeyValue  ='FirstReleaseDeferred';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        DisplayName = 'Beta';
                                        KeyValue = 'InsiderFast';
                                    }

# Select New Update Channel
$UpdateChannel = $UpdateChannels | Where-Object DisplayName -Eq 'Monthly Enterprise' 

# Set New Update Channel
If (-Not(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate') -eq $true) {New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Force}
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name updatebranch -Value $UpdateChannel.KeyValue -PropertyType String -Force -ea SilentlyContinue