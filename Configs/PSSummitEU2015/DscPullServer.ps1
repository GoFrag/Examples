#region Generate certificate to be used to encrypt passwords in Pull Server config
$Certificate = ls Cert:\LocalMachine\My | ? {$_.Subject -eq "CN=$env:COMPUTERNAME" -and $_.PrivateKey.KeyExchangeAlgorithm} | Select -First 1 
if(!$Certificate)
{
    $Certificate = New-SelfSignedCertificate -Provider 'Microsoft RSA SChannel Cryptographic Provider' -DnsName $env:COMPUTERNAME -CertStoreLocation 'Cert:\LocalMachine\My'
}

#endregion Generate certificate to be used to encrypt passwords in Pull Server config

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            CertificateID = $Certificate.Thumbprint
            }
    )
}

$SSLCertFilePath = 'C:\Git\Examples\Configs\PSSummitEU2015\my_ssl.pfx'

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