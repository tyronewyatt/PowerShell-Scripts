# Continue Silently on Error
$ErrorActionPreference = 'SilentlyContinue'

Write-Host 'Application Deployment Evaluation Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000121}") {$True} Else {$False}

Write-Host 'Discovery Data Collection Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000003}") {$True} Else {$False}

Write-Host 'File Collection Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000010}") {$True} Else {$False}

Write-Host 'Hardware Inventory Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000001}") {$True} Else {$False}

Write-Host 'Machine Policy Retrieval Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000021}") {$True} Else {$False}

Write-Host 'Machine Policy Evaluation Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000022}") {$True} Else {$False}

Write-Host 'Software Inventory Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000002}") {$True} Else {$False}

Write-Host 'Software Metering Usage Report Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000031}") {$True} Else {$False}

Write-Host 'Software Update Deployment Evaluation Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000114}") {$True} Else {$False}

Write-Host 'Software Update Scan Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000113}") {$True} Else {$False}

Write-Host 'State Message Refresh'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000111}") {$True} Else {$False}

Write-Host 'Windows Installers Source List Update Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000032}") {$True} Else {$False}

<#
Write-Host 'User Policy Retrieval Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000026}") {$True} Else {$False}

Write-Host 'User Policy Evaluation Cycle'
If (Invoke-WMIMethod -Namespace root\ccm -Class SMS_CLIENT -Name TriggerSchedule "{00000000-0000-0000-0000-000000000027}") {$True} Else {$False}
#>