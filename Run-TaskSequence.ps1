# Retrieve the name of the task sequence that should be executed
$TaskSequenceName = "Upgrade to Windows 10 Enterprise, version 21H2"

# Retrieve the PackageID and AdvertisementID from the machine actual policy
$SoftwareDistributionPolicy = Get-WmiObject -Namespace "root\ccm\policy\machine\actualconfig" -Class "CCM_SoftwareDistribution" | Where-Object { $_.PKG_Name -like $TaskSequenceName } | Select-Object -Property PKG_PackageID, ADV_AdvertisementID

# Retrieve the ScheduleID used for triggering a new required assignment for task sequence
$ScheduleID = Get-WmiObject -Namespace "root\ccm\scheduler" -Class "CCM_Scheduler_History" | Where-Object { $_.ScheduleID -like "*$($SoftwareDistributionPolicy.PKG_PackageID)*" } | Select-Object -ExpandProperty ScheduleID

# Check if the RepeatRunBehavior is set to RerunAlways, if not change the value
$TaskSequencePolicy = Get-WmiObject -Namespace "root\ccm\policy\machine\actualconfig" -Class "CCM_TaskSequence" | Where-Object { $_.ADV_AdvertisementID -like $SoftwareDistributionPolicy.ADV_AdvertisementID }
if ($TaskSequencePolicy.ADV_RepeatRunBehavior -notlike "RerunAlways") {
    $TaskSequencePolicy.ADV_RepeatRunBehavior = "RerunAlways"
    $TaskSequencePolicy.Put() | Out-Null
}

# Set the mandatory assignment property to true mimicing it contains assignments
$TaskSequencePolicy.Get()
$TaskSequencePolicy.ADV_MandatoryAssignments = $true
$TaskSequencePolicy.Put() | Out-Null

# Invoke the mandatory assignment
Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "TriggerSchedule" -ArgumentList $ScheduleID