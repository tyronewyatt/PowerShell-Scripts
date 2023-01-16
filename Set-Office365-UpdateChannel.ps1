# Update Channels
$UpdateChannels = @()
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Current';
                                        Value='Current';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Current (Preview)';
                                        Value='FirstReleaseCurrent';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Monthly Enterprise';
                                        Value='MonthlyEnterprise';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Semi-Annual Enterprise';
                                        Value='Deferred';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Semi-Annual Enterprise (Preview)';
                                        Value='FirstReleaseDeferred';
                                    }
$UpdateChannels += [PSCustomObject] @{
                                        Channel='Beta';
                                        Value='InsiderFast';
                                    }

# Select New Update Channel
$UpdateChannel = $UpdateChannels | Where-Object Channel -Eq 'Monthly Enterprise' 

# Set New Update Channel
If (-Not(Test-Path -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate') -eq $true) {New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Force}
New-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\office\16.0\common\officeupdate' -Name updatebranch -Value $UpdateChannel.Value -PropertyType String -Force -ea SilentlyContinue