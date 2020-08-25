Param(
[string]$SchoolPrefix = '0000',
[string]$NetworkName = 'eduSTAR',
[switch]$EducationDomain = $False,
[string]$ScriptPath = '\\tsccm01.tallangatta-sc.vic.edu.au\SourceFiles\Packages\eduSTAR.net',
[string]$CertificatePath = '\\tscfs01.tallangatta-sc.vic.edu.au\eduSTAR.net$',
[string]$CertificatePassword = 'xxxxxx'
)

# Trusted root CA thumbprint
$TrustedRootCA = '70 41 c4 af 52 ec 45 2a 79 9a d2 7b a1 71 c3 09 67 04 ae bd'

# Trusted servers
$ServerNames = '*.education.vic.gov.au,*.services.education.vic.gov.au'

# Set SSID by uncommenting relevant entry
$SSID = @()
$SSID += [PSCustomObject] @{Name='eduSTAR';Hex='65647553544152'}
$SSID += [PSCustomObject] @{Name='eduSTAR_A';Hex='656475535441525f41'}
$SSID += [PSCustomObject] @{Name='eduSTAR_B';Hex='656475535441525f42'}
$SSID = $SSID | Where-Object Name -Eq $NetworkName

# Convert certificate password to secure password
$SecureCertificatePassword = ConvertTo-SecureString –AsPlainText -Force -String $CertificatePassword

# Generate eduSTAR EAP-TLS profile for machine authentication
$ProfileEAPTLS = `
"<?xml version=`"1.0`"?>
<WLANProfile xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v1`">
	<name>$($SSID.Name)</name>
	<SSIDConfig>
		<SSID>
			<hex>$($SSID.Hex)</hex>
			<name>$($SSID.Name)</name>
		</SSID>
		<nonBroadcast>false</nonBroadcast>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<autoSwitch>false</autoSwitch>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2</authentication>
				<encryption>AES</encryption>
				<useOneX>true</useOneX>
			</authEncryption>
			<OneX xmlns=`"http://www.microsoft.com/networking/OneX/v1`">
				<cacheUserData>true</cacheUserData>
				<authMode>machine</authMode>
				<EAPConfig>
					<EapHostConfig xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
						<EapMethod>
							<Type xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">13</Type>
							<VendorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorId>
							<VendorType xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorType>
							<AuthorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</AuthorId>
						</EapMethod>
						<Config xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
							<Eap xmlns=`"http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1`">
								<Type>13</Type>
								<EapType xmlns=`"http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1`">
									<CredentialsSource>
										<CertificateStore>
											<SimpleCertSelection>true</SimpleCertSelection>
										</CertificateStore>
									</CredentialsSource>
									<ServerValidation>
										<DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>
										<ServerNames>$ServerNames</ServerNames>
										<TrustedRootCA>$TrustedRootCA </TrustedRootCA>
									</ServerValidation>
									<DifferentUsername>false</DifferentUsername>
									<PerformServerValidation xmlns=`"http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2`">true</PerformServerValidation>
									<AcceptServerName xmlns=`"http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV2`">false</AcceptServerName>
								</EapType>
							</Eap>
						</Config>
					</EapHostConfig>
				</EAPConfig>
			</OneX>
		</security>
	</MSM>
</WLANProfile>"

# Generate eduSTAR PEAP WLAN profile for user authentication
$ProfilePEAP = `
"<?xml version=`"1.0`"?>
<WLANProfile xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v1`">
	<name>$($SSID.Name)</name>
	<SSIDConfig>
		<SSID>
			<hex>$($SSID.Hex)</hex>
			<name>$($SSID.Name)</name>
		</SSID>
	</SSIDConfig>
	<connectionType>ESS</connectionType>
	<connectionMode>auto</connectionMode>
	<MSM>
		<security>
			<authEncryption>
				<authentication>WPA2</authentication>
				<encryption>AES</encryption>
				<useOneX>true</useOneX>
			</authEncryption>
			<PMKCacheMode>enabled</PMKCacheMode>
			<PMKCacheTTL>720</PMKCacheTTL>
			<PMKCacheSize>128</PMKCacheSize>
			<preAuthMode>disabled</preAuthMode>
			<OneX xmlns=`"http://www.microsoft.com/networking/OneX/v1`">
				<authMode>user</authMode>
				<EAPConfig>
					<EapHostConfig xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
						<EapMethod>
							<Type xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">25</Type>
							<VendorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorId>
							<VendorType xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorType>
							<AuthorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</AuthorId>
						</EapMethod>
						<Config xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
							<Eap xmlns=`"http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1`">
								<Type>25</Type>
								<EapType xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1`">
									<ServerValidation>
										<DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>
										<ServerNames>$ServerNames</ServerNames>
										<TrustedRootCA>$TrustedRootCA </TrustedRootCA>
									</ServerValidation>
									<FastReconnect>true</FastReconnect>
									<InnerEapOptional>false</InnerEapOptional>
									<Eap xmlns=`"http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1`">
										<Type>26</Type>
										<EapType xmlns=`"http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1`">
											<UseWinLogonCredentials>false</UseWinLogonCredentials>
										</EapType>
									</Eap>
									<EnableQuarantineChecks>false</EnableQuarantineChecks>
									<RequireCryptoBinding>false</RequireCryptoBinding>
									<PeapExtensions>
										<PerformServerValidation xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">true</PerformServerValidation>
										<AcceptServerName xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">true</AcceptServerName>
										<PeapExtensionsV2 xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">
											<AllowPromptingWhenServerCANotFound xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV3`">true</AllowPromptingWhenServerCANotFound>
										</PeapExtensionsV2>
									</PeapExtensions>
								</EapType>
							</Eap>
						</Config>
					</EapHostConfig>
				</EAPConfig>
			</OneX>
		</security>
	</MSM>
	<MacRandomization xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v3`">
		<enableRandomization>false</enableRandomization>
		<randomizationSeed>2414084357</randomizationSeed>
	</MacRandomization>
</WLANProfile>"

# Generate eduSTAR PEAP user authentication with EAP-TLS pre-authentication machine authentication WLAN profile
$ProfilePEAPSSO = `
"<?xml version=`"1.0`"?>
<WLANProfile xmlns=`"http://www.microsoft.com/networking/WLAN/profile/v1`">
    <name>$($SSID.Name)</name>
    <SSIDConfig>
        <SSID>
            <hex>$($SSID.Hex)</hex>
            <name>$($SSID.Name)</name>
        </SSID>
        <nonBroadcast>false</nonBroadcast>
    </SSIDConfig>
    <connectionType>ESS</connectionType>
    <connectionMode>auto</connectionMode>
    <autoSwitch>true</autoSwitch>
    <MSM>
        <security>
            <authEncryption>
                <authentication>WPA2</authentication>
                <encryption>AES</encryption>
               <useOneX>true</useOneX>
            </authEncryption>
            <PMKCacheMode>enabled</PMKCacheMode>
            <PMKCacheTTL>720</PMKCacheTTL>
            <PMKCacheSize>128</PMKCacheSize>
            <preAuthThrottle>3</preAuthThrottle>
           <OneX xmlns=`"http://www.microsoft.com/networking/OneX/v1`">
                <cacheUserData>true</cacheUserData>
                <maxAuthFailures>2</maxAuthFailures>
                <authMode>user</authMode>
                <singleSignOn>
                    <type>preLogon</type>
                    <maxDelay>20</maxDelay>
                    <allowAdditionalDialogs>false</allowAdditionalDialogs>
                    <userBasedVirtualLan>false</userBasedVirtualLan>
               </singleSignOn>
                <EAPConfig>
                    <EapHostConfig xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
                        <EapMethod>
                            <Type xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">25</Type>
                            <VendorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorId>
                            <VendorType xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</VendorType>
                            <AuthorId xmlns=`"http://www.microsoft.com/provisioning/EapCommon`">0</AuthorId>
                        </EapMethod>
                        <Config xmlns=`"http://www.microsoft.com/provisioning/EapHostConfig`">
                            <Eap xmlns=`"http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1`">
                                <Type>25</Type>
                                <EapType xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1`">
                                    <ServerValidation>
                                        <DisableUserPromptForServerValidation>false</DisableUserPromptForServerValidation>
										<ServerNames>$ServerNames</ServerNames>
										<TrustedRootCA>$TrustedRootCA </TrustedRootCA>
                                    </ServerValidation>
                                    <FastReconnect>true</FastReconnect>
                                    <InnerEapOptional>false</InnerEapOptional>
                                    <Eap xmlns=`"http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1`">
                                        <Type>26</Type>
                                       <EapType xmlns=`"http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1`">
                                            <UseWinLogonCredentials>true</UseWinLogonCredentials>
                                        </EapType>
                                    </Eap>
                                    <EnableQuarantineChecks>false</EnableQuarantineChecks>
                                    <RequireCryptoBinding>false</RequireCryptoBinding>
                                    <PeapExtensions>
                                        <PerformServerValidation xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">true</PerformServerValidation>
                                        <AcceptServerName xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">false</AcceptServerName>
                                        <PeapExtensionsV2 xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV2`">
                                            <AllowPromptingWhenServerCANotFound xmlns=`"http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV3`">true</AllowPromptingWhenServerCANotFound>
                                        </PeapExtensionsV2>
                                    </PeapExtensions>
                                </EapType>
                            </Eap>
                        </Config>
                    </EapHostConfig>
                </EAPConfig>
            </OneX>
        </security>
    </MSM>
</WLANProfile>"

# Run if system is a mobile device 
If ((Get-WmiObject Win32_ComputerSystem).PCSystemType -Eq '2')
    {
    # Start wireless LAN service
    $WlanSvc = Get-Service -DisplayName 'WLAN AutoConfig'
    $WlanSvc | Where {$_.Status -Eq 'Stopped'} | Start-Service 
    $WlanSvc.WaitForStatus('Running')

    # Remove old WLAN profile
    NetSh WLAN Delete Profile "$($SSID.Name)"

    # Remove machine certificate/s
    Get-ChildItem Cert:\LocalMachine\My | Where-Object {$_.Subject -Match "$SchoolPrefix-"} | Remove-Item

    # Import education root certificate
    Import-Certificate –FilePath '.\eduRootCA01.pem' -CertStoreLocation Cert:\LocalMachine\Root

    # Import educaion intermediate certificates
    Import-Certificate –FilePath '.\EDUSUBCA01.pem' -CertStoreLocation Cert:\LocalMachine\CA
    Import-Certificate –FilePath '.\EDUSUBCA02.pem' -CertStoreLocation Cert:\LocalMachine\CA

    # Import schools intermediate certificates
    Import-Certificate –FilePath '.\STASUBCA01.pem' -CertStoreLocation Cert:\LocalMachine\CA
    Import-Certificate –FilePath '.\STASUBCA02.pem' -CertStoreLocation Cert:\LocalMachine\CA

    # Generate certificate name
    $SerialNumber = (Get-WmiObject Win32_BIOS).SerialNumber
    $CertificateName = "$SchoolPrefix-$SerialNumber.pfx"

    #Gererate profile name
    $WlanProfile = $($SSID.Name) + '-Profile.xml'

    # Test if certificate exists, if so user machine authentication else user authentication
    If (Test-Path "$CertificatePath\$CertificateName" -And $EducationDomain -Eq $False)
        {
        # Import machine certificate
        Import-PfxCertificate –FilePath "$CertificatePath\$CertificateName" Cert:\LocalMachine\My -Password $SecureCertificatePassword

        # Export eduSTAR EAP-TLS profile for machine authentication
        $ProfileEAPTLS | Out-File -Encoding utf8 -FilePath $env:TEMP\$WlanProfile
        
        # Import eduSTAR EAP-TLS profile for machine authentication
        NetSh WLAN Add Profile FileName = $env:TEMP\$WlanProfile

        # Connect to eduSTAR network
        NetSh WLAN Connect Name = "$($SSID.Name)"
        }
    Else
        {
        # Export eduSTAR PEAP WLAN profile for user authentication
        $ProfilePEAP | Out-File -Encoding utf8 -FilePath $env:TEMP\$WlanProfile

        # Import eduSTAR PEAP WLAN profile for user authentication
        NetSh WLAN Add Profile FileName = $env:TEMP\$WlanProfile
        }
    If ($EducationDomain -Eq $True)
        {
        # Export eduSTAR PEAP user authentication with EAP-TLS pre-authentication machine authentication WLAN profile
        $ProfilePEAPSSO | Out-File -Encoding utf8 -FilePath $env:TEMP\$WlanProfile
        
        # Import eduSTAR PEAP user authentication with EAP-TLS pre-authentication machine authentication WLAN profile
        NetSh WLAN Add Profile FileName = $env:TEMP\$WlanProfile
        }
    # Remove eduSTAR profile
    Remove-Item $env:TEMP\$WLANProfile
    }
Exit 0