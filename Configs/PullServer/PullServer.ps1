if((get-Module -Name xPSDesiredStateConfiguration) -eq $null)
{
    Install-Module -Name xPSDesiredStateConfiguration
}

configuration secureDSCPullServer
{
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    $CertSubject = "CN=DscPull.Contoso.com"
    $CertPassword = read-host -Prompt "Enter certificate password" -AsSecureString

    Node localhost
    {
        xPfxCertificate SSLWebsiteCert
        {
            Ensure    = "Present"
            FilePath  = "c:\cert\sslcert.pfx"
            Subject   = $CertSubject
            StoreLocation  = "Cert:\LocalMachine\My"
            Password  = $CertPassword
        }
    
        xDSCWebService PullServer
        {
            Ensure = "Present"
            State = "Started"
            EndpointName = "PSDSCPullServer"
            PhysicalPath = "c:\inetpub\dscpullserver"
            Port = "80"
            CertificateThumbPrint = "Use Subject to discover thumbprint"
            CertificateSubject = $CertSubject
            ModulePath = "c:\DscService\Modules"
            ConfigurationPath = "c:\DscService\Modules"
            IsComplianceServer = $false
        }
    }
}