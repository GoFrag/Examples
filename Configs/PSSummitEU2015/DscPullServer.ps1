

$SSLCertFilePath = 'C:\Configs\my_ssl.pfx'
$SSLThumbprint = (Get-PfxCertificate -FilePath $SSLCertFilePath).Thumbprint
$SSLCert = dir "Cert:\LocalMachine\My\$SSLThumbprint"

if(!$SSLCert)
{
    $SSLCertPassword = Read-Host -Prompt 'Enter Password for SSL Certificate:' -AsSecureString

    #Import SSL cert for use by website
    Import-PfxCertificate -FilePath $SSLCertFilePath -CertStoreLocation 'cert:\LocalMachine\My' -Password $SSLCertPassword

    #Import SSL cert into trusted root
    Import-PfxCertificate -FilePath $SSLCertFilePath -CertStoreLocation 'cert:\LocalMachine\root' -Password $SSLCertPassword
}

Configuration V2PullServer
{
    param(
            [Parameter(Mandatory)]
            [ValidateNotNullOrEmpty()]
            [string] $SSLCertThumbprint
    )

    Import-DscResource -ModuleName xPsDesiredStateConfiguration

    node localhost
    {
        WindowsFeature DSCServiceFeature
        {
            Ensure = "Present"
            Name   = "DSC-Service"            
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

        File RegistrationKeyFile
        {
            Ensure ='Present'
            Type = 'File'
            DestinationPath = "$env:ProgramFiles\WindowsPowerShell\DscService\RegistrationKeys.txt"
            Contents = '9a28a925-18d9-4689-a591-5a0c53ab73b2'
        }
    }
}

V2PullServer -SSLCertThumbprint $SSLThumbprint -OutputPath c:\Configs\MOF 

#Start-DscConfiguration -Path C:\Configs\MOF\ -Wait -Verbose