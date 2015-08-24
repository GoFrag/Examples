

Configuration V2PullServer
{
    Import-DscResource -ModuleName xPsDesiredStateConfiguration

    WindowsFeature DSCServiceFeature
    {
        Ensure = "Present"
        Name   = "DSC-Service"            
    }

    #Resource to install SSL Certificate

    xDscWebService PSDSCPullServer
    {
        Ensure                       = "Present"
        EndpointName                 = "PSDSCPullServer"
        Port                         = 443
        PhysicalPath                 = "$env:SystemDrive\inetpub\wwwroot\PSDSCPullServer"
        CertificateThumbPrint        = "3BD95654606A208CFF8B3316A0545F383592DBF5"         
        ModulePath                   = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Modules"
        ConfigurationPath            = "$env:PROGRAMFILES\WindowsPowerShell\DscService\Configuration"            
        State                        = "Started"
        DependsOn                    = "[WindowsFeature]DSCServiceFeature" 
        RegistrationKeyPath          = "$env:PROGRAMFILES\WindowsPowerShell\DscService"   
        AcceptSelfSignedCertificates = $true
    }
}

V2PullServer -OutputPath c:\Configs\