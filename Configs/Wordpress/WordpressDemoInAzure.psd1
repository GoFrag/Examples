
# ********* NOTE ***********
# PHP and My SQL change their download URLs frequently.  Please verify the URLs.
# the WordPress and VC Redist URL change less frequently, but should still be verified.
# After verifying the download URLs for the products and update them appropriately.
# **************************

@{
AllNodes = @(        
        @{
            NodeName = "*"
            PSDscAllowPlainTextPassword = $true;
            DatabaseName = "Wordpress"
        },
        @{
            NodeName = "localhost"
            DeploymentStage = "Production"
            Role = "WordPress"

            DownloadRootURI = "https://dscprod.blob.core.windows.net/source"
            DownloadDesintinationRootPath = ""
            
            MySqlServiceName = "MySqlServer100"
            MySqlDownloadURI = "https://dscprod.blob.core.windows.net/source/mysql-installer-community-5.6.20.0.msi"
            MySqlProductID = "{E7E2D467-1D19-4F8E-8BB3-D49569471702}"
            MySqlProductName = "MySQL Installer"

            WordPress = @{
                Title = "Contoso Website"
                Email = "dscadmin@contoso.com"
                Uri = "http://fourthcoffee.cloudapp.net"
                DownloadURI = "https://dscprod.blob.core.windows.net/source/wordpress-4.0.zip"
                Path = "c:\inetpub\wordpress"
                IisSiteName = "WordPress"
                DbHostName = "localhost"
            }    
            
            Php = @{
                DownloadURI = "https://dscprod.blob.core.windows.net/source/php-5.5.16-nts-Win32-VC11-x64.zip"
                TemplatePath = "c:\program files\WindowsPowerShell\Modules\xWordpress\Samples\phpConfigTemplate.txt"
                Path = "c:\php"
                Vc2012RedistUri = "https://dscprod.blob.core.windows.net/source/vcredist_x64.exe"
            }
            
         }
    )  
}