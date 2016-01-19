Configuration Web
{
    Import-DscResource -ModuleName xWebAdministration

    Node localhost
    {           
        xWebsite Default
        {
            Ensure          = "Present"
            Name            = "Default Web Site"
            PhysicalPath    = "C:\inetpub\wwwroot"
        }
       
        xWebsite ContosoSite
        {
            Ensure          = "Present"
            Name            = "Contoso"
            State           = "Started"
            PhysicalPath    = "c:\inetpub\Contoso"
            DefaultPage     = "Default.aspx"
            BindingInfo     = MSFT_xWebBindingInformation 
                             { 
                               Protocol  = "HTTP" 
                               Port      = 80
                             } 
        }

        xWebAppPool ContosoAppPool
        {
            Ensure    = "Present"
            Name      = "ContosoAppPool"
            State     = "Started"
        }

        xWebApplication ContosoWebApp
        {
            Ensure       = "Present"
            Name         = "WebApp"
            WebAppPool   = "ContosoAppPool"
            Website      = "Contoso"
            PhysicalPath = "C:\Program Files\Contoso\Corp WebApp"
        }
 
        xWebVirtualDirectory Images
        {
            Ensure         = "Present"
            Website        = "Contoso"
            WebApplication = "WebApp"
            Name           = "Images"
            PhysicalPath   = "C:\Program Files\Contoso\Common Images"
        }

        xWebConfigKeyValue ModifyWebConfig 
        { 
          Ensure         = "Present" 
          ConfigSection  = "AppSettings" 
          key            ="emailto"
          value          ="me@nowhere.net" 
          IsAttribute    = $false 
          WebsitePath    = "IIS:\Sites\Contoso\WebApp\"   
        } 
    }
}

Web -OutputPath c:\temp\Web 

#Start-DscConfiguration -Path c:\temp\Web\ -Wait -Verbose -Force