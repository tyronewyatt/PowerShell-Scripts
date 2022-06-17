$SMSTSMachineName = (New-Object -COMObject Microsoft.SMS.TSEnvironment).Value('_SMSTSMachinename')
If ($SMSTSMachineName -Like 'MININT-*')
    {
    # Get Wmi Objects
    $SerialNumber = (Get-WmiObject Win32_BIOS).SerialNumber

    # Normalize Serial Number
    $SerialNumber = $SerialNumber -Replace '[-._ ]',''

    # Set Serial Number Length
    $SerialNumber = $SerialNumber.SubString(0,15)

    # Set ComputerName Variable
    $OSDComputerName = $SerialNumber

    # Set Computer Name in Operating System Deployment
    Write-Output $OSDComputerName
    }
Else
    {Write-Output $SMSTSMachineName}