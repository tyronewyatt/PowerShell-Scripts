﻿Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -Eq "Microsoft.Whiteboard"} | Remove-AppxProvisionedPackage -AllUsers -Online