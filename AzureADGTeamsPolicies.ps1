Install-Module -Name MSonline
Install-Module -Name MicrosoftTeams

Import-Module MSOnline
connect-msolservice

Connect-MicrosoftTeams


Get-AzureAdSubscribedSku | Select-Object -Property SkuPartNumber,SkuId



$faculty = Get-AzureADUser -All $true | Where-Object {($_.assignedLicenses).SkuId -contains "78e66a63-337a-4a9a-8959-41c6654dfb56"} 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMeetingPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMeetingBroadcastPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsChannelsPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsCallingPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppSetupPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppPermissionPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMessagingPolicy -PolicyName "Education_Teacher" -Identity $faculty.ObjectId 


$faculty = Get-AzureADUser -All $true | Where-Object {($_.assignedLicenses).SkuId -contains "e82ae690-a2d5-4d76-8d30-7c6e01e6022e"} 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMeetingPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMeetingBroadcastPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsChannelsPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsCallingPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppSetupPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsAppPermissionPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 
New-CsBatchPolicyAssignmentOperation -PolicyType TeamsMessagingPolicy -PolicyName "Education_SecondaryStudent" -Identity $faculty.ObjectId 