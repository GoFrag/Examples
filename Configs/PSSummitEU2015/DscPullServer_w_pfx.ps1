#region Generate certificate to be used to encrypt passwords in Pull Server config
$Certificate = ls Cert:\LocalMachine\My | ? {$_.Subject -eq "CN=$env:COMPUTERNAME" -and $_.EnhancedKeyUsageList.ObjectID -eq '1.3.6.1.4.1.311.80.1'} | Select -First 1 
if(!$Certificate)
{
    $Certificate = New-SelfSignedCertificate -KeyUsage DataEncipherment -Type DocumentEncryptionCert -DnsName $env:COMPUTERNAME -CertStoreLocation 'Cert:\LocalMachine\My'
}

#endregion Generate certificate to be used to encrypt passwords in Pull Server config

[DscLocalConfigurationManager()]
Configuration Meta
{
    Settings
    {
        #Thumbprint of Certificate to be used to decrypt credentails within configuations on this node
        CertificateID = $Certificate.Thumbprint
    }
}

Meta -OutputPath c:\configs\MOF\

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            #Thumprint of certificate to be used to encrypt credentials within a configuration
            CertificateID = $Certificate.Thumbprint
            }
    )
}

$SSLCertFilePath = 'C:\Configs\my_ssl.pfx'

Configuration V2PullServer
{
    param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()] 
            [pscredential] $SSLCertificatePassword,

            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string] $SSLCertThumbprint
    )

    Import-DscResource -ModuleName xPsDesiredStateConfiguration
    Import-DscResource -ModuleName xCertificate
    node localhost
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"            
        }

        #Resource to install SSL Certificate
        xPfxCertificate PullServerSSCert
        {
            Ensure = 'Present'
            FilePath = $SSLCertFilePath
            CertStoreLocation = 'Cert:\LocalMachine\My'
            Password = $SSLCertificatePassword
            Exportable = $false
        }

        xDscWebService PSDSCPullServer
        {
            Ensure                       = "Present"
            EndpointName                 = "PSDSCService"
            Port                         = 443
            PhysicalPath                 = "c:\inetpub\PullServer"
            CertificateThumbPrint        = $SSLCertThumbprint                  
            State                        = "Started"
            DependsOn                    = "[WindowsFeature]DSCServiceFeature" 
            AcceptSelfSignedCertificates = $true
        }
    }
}

$SSLcred = Get-Credential -Message 'Enter Password for pfx certificate: ' -UserName 'None'
$SSLThumbprint = (Get-PfxCertificate -FilePath $SSLCertFilePath).Thumbprint

V2PullServer -SSLCertificatePassword $SSLcred -SSLCertThumbprint $SSLThumbprint -ConfigurationData $ConfigData -OutputPath c:\Configs\MOF 

#Start-DscConfiguration -Path C:\Configs\MOF\ -Wait -Verbose