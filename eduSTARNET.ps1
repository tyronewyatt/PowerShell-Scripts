# Define settings
$SchoolPrefix = '8370'
$SSID = 'eduSTAR'
$CertificatePath = '\\tallangatta-sc.vic.edu.au\Tools$\eduSTAR.net'
$CertificatePassword = ConvertTo-SecureString –AsPlainText -Force -String 'xxxxxx'

# Mobile device system
If ((Get-WmiObject Win32_ComputerSystem).PCSystemType -Eq 2)
    {
    # Start wireless LAN service
    $WlanSvc = Get-Service -DisplayName 'WLAN AutoConfig'
    $WlanSvc | Where {$_.Status -Eq 'Stopped'} | Start-Service 
    $WlanSvc.WaitForStatus('Running')

    # Remove old WLAN profile
    NetSh WLAN Delete Profile "$SSID"

    # Remove machine certificate
    Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$SchoolPrefix-"} | Remove-Item

    # Import education root certificate
    Import-Certificate –FilePath ".\eduRootCA01.pem" -CertStoreLocation Cert:\LocalMachine\Root

    # Import educaion intermediate certificate
    Import-Certificate –FilePath ".\EDUSUBCA01.pem" -CertStoreLocation Cert:\LocalMachine\CA
    Import-Certificate –FilePath ".\EDUSUBCA02.pem" -CertStoreLocation Cert:\LocalMachine\CA

    # Import schools intermediate certificate
    Import-Certificate –FilePath ".\STASUBCA01.pem" -CertStoreLocation Cert:\LocalMachine\CA
    Import-Certificate –FilePath ".\STASUBCA02.pem" -CertStoreLocation Cert:\LocalMachine\CA

    # Generate certificate name
    $SerialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
    $CertificateName = "$SchoolPrefix-$SerialNumber.pfx"

    # Test if certificate exists
    If (Test-Path "$CertificatePath\$CertificateName")
        {
        # Import machine certificate
        Import-PfxCertificate –FilePath "$CertificatePath\$CertificateName" Cert:\LocalMachine\My -Password $CertificatePassword

        # Import eduSTAR PEAP WLAN profile for machine authentication
        NetSh WLAN Add Profile FileName = ".\eduSTARPEAP.xml"

        # Connect to eduSTAR network
        NetSh WLAN Connect Name = "$SSID"
        }
    Else
        {
        # Import eduSTAR EAP-TLS profile for user authentication
        NetSh WLAN Add Profile FileName = ".\eduSTAREAPTLS.xml"
        }
    }