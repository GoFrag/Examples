Configuration IISWebsite 
{
    Import-DSCResource -Module xWebAdministration	

    Node IIS1
    {
	    WindowsFeature IIS
	    {
		    Ensure = “Present”
		    Name = “Web-Server”
        }

        WindowsFeature ASP
	    {
		    Ensure = “Present”
		    Name = “Web-Asp-Net45”
        }

        xWebsite DefaultSite
        {
	        Ensure = “Present”
	        Name = “Default Web Site”
	        PhysicalPath = “c:\inetpub\wwwroot”
	        State = “Stopped”
	        DependsOn = “[windowsFeature]IIS”
        } 

        File WebContent
        {
            Ensure = "Present"
            Type = "Directory"
            SourcePath = "C:\Source\BakeryWebsite"
            DestinationPath = "C:\inetpub\FourthCoffee"
            Recurse = $true
        }

        xWebsite FouthCoffeeBakeryWebsite
        {
	        Ensure = “Present”
	        Name = “FourthCoffeeBakery”
	        PhysicalPath = “c:\inetpub\FourthCoffee”
	        State = “Started”
            BindingInfo = MSFT_xWebBindingInformation{Port=80;Protocol="Http"}
            DependsOn = “[File]WebContent”
        } 
    }
} 

Website