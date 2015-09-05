
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

        #Install WebApp for managing Configurations / resources
        #set-webconfiguration "/system.applicationHost/applicationPools/add[@name=$sitename]/@enable32BitAppOnWin64" -Value "true"
        #set-itemProperty IIS:\apppools\$sitename -name "enable32BitAppOnWin64" -Value "true"
    }
}

$SSLCertFilePath = "$PSScriptRoot\fabricam_ssl.pfx"
$SSLThumbprint = (Get-PfxCertificate -FilePath $SSLCertFilePath).Thumbprint

V2PullServer -SSLCertThumbprint $SSLThumbprint -OutputPath C:\Demos\PSSummitEurope2015\MOF