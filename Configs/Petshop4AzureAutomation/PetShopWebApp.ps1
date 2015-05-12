Configuration PetShopWebApp
{
    param(
        #[parameter(Mandatory)][String] $SQLsaCred, 
        [parameter(Mandatory)][String] $SQLUserName,
        [parameter(Mandatory)][String] $SQLPassword,
        [string] $SampleScriptURI = "https://petshopdata2.blob.core.windows.net/packages/SampleData.sql",
        [string] $sqlInstanceName = "",
        [parameter(Mandatory)][string] $SQLServerName,
        [string] $WebsitePath = "c:\inetpub\MSPetShop",
        [string] $WebAppName = "MSPetShop",
        [int32] $WebsitePort = 80,
        [string] $WebDeployURI = "https://petshopdata2.blob.core.windows.net/packages/WebDeploy_amd64_en-US.msi",
        [string] $WebPackageURI = "https://petshopdata2.blob.core.windows.net/packages/petshop.zip",
        [string] $WebPackagePath = "c:\data\petshop.zip"
    )

    Import-DSCResource -Module xWebAdministration
    Import-DSCResource -Module xWebDeploy
    Import-DSCResource -Module xSqlPs
    Import-DSCResource -Module xNetworking
    Import-DscResource -module xFileContent
    Import-DscResource -module xPSDesiredStateConfiguration

    #Configure SQL backend
    Node SQL
    {
        $sqlInstanceName = ".\$SqlInstanceName"
        $CacheScriptContent = {$appcmd = "$env:SystemDrive\WINDOWS\Microsoft.NET\Framework\v2.0.50727\aspnet_regsql.exe"; `
                        & $appcmd -S .\ -U OaaS -P pass@word1 -A all -d MSPetShop4Services; `
                        & $appcmd -S .\ -U OaaS -P pass@word1 -d MSPetShop4 -ed; `
                        & $appcmd -S .\ -U OaaS -P pass@word1 -d MSPetShop4 -t Item -et; `
                        & $appcmd -S .\ -U OaaS -P pass@word1 -d MSPetShop4 -t Product -et; `
                        & $appcmd -S .\ -U OaaS -P pass@word1 -d MSPetShop4 -t Category -et; `
                        echo "Database Caching successfully enabled. Username=OaaS, Password=pass@word1, Database=MSPetShop4" >> $env:ALLUSERSPROFILE\CacheScript.txt
                      }
           
         # Example Resources for how to Install SQL
         <# This config assumes that SQL is already installed only to save time.
         # Net 3.5 is required for installing sql server
         WindowsFeature InstallDotNet35
         {            
            Ensure = "Present"
            Name = "Net-Framework-Core"
            Source = "$env:systemDrive\sxs"           

         }
         # Install SQL Server
        xSqlServerInstall InstallSqlServerFullEnterprise
        {
            InstanceName = $Node.SqlInstanceName
            SourcePath = "$env:systemDrive\SQLEnterprise"           
            Features = "SQLEngine,SSMS"            
            SqlAdministratorCredential = $SQLsaCred
            DependsOn = "[WindowsFeature]InstallDotNet35"
        }
        #>

        #Enable Remove Access to SQL Engine and SQL browser
	    xFireWall EnableRemoteAccessOnSQLBrowser
        {

            Name = "SqlBrowser"
            Ensure = "Present"
            Access = "Allow"
            State ="Enabled"
            ApplicationPath = "c:\Program Files\Microsoft SQL Server\90\Shared\sqlbrowser.exe"
            Profile = "Any"
        }

        xFireWall EnableRemoteAccessOnSQLEngine
        {
            Name = "SqlServer"
            Ensure = "Present"
            Access = "Allow"
            State ="Enabled"
            ApplicationPath = "c:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\Binn\sqlservr.exe"
            Profile = "Any"
        }
	          
        # Provisioning databases with some pet information
        xRemoteFile PetshopSampleDataScript
        {
            Uri = $SampleScriptURI
            DestinationPath = "c:\programdata\SampleData.sql"
        }

        xOSql PetShopSampleData
        {
            SQLServer = $SQLServerName
            SqlUserName = $SQLUserName
            SqlPassword = $SQLPassword
            SQLFilePath = "c:\programdata\SampleData.sql"
        }

        #Enables sql database caching 
        Script PetShopSQLCacheDependency                       
        {
            SetScript = $CacheScriptContent
            GetScript = {@{}} #no easy way to get the sql database cache flag
            TestScript = {if(Test-path c:\programdata\CacheScript.txt){if((get-content c:\programdata\CacheScript.txt) -match "Username=OaaS, Password=pass@word1, Database=MSPetShop4"){return $true}else{return $false}}else{return $false}}
        }
   }

    #Configure IIS front end
    Node IIS
    {
        # Install IIS and  Web Management Tools
        WindowsFeature InstallWebServer
        {
            Name = "Web-server"
            Ensure = "Present"
            IncludeAllSubFeature = $true
         }

        WindowsFeature InstallIISManagementTools
        {
            Name = "Web-Mgmt-Tools"
            Ensure = "Present"
            IncludeAllSubFeature = $true
         }
        
        xWebsite Default
        {
            Ensure = "Present"
            Name = "Default Web Site"
            PhysicalPath = "%SystemDrive%\inetpub\wwwroot"
            State = "Stopped"
        }

        File WebsiteDirectory
        {
            Ensure ="Present"
            Type = "Directory"
            DestinationPath = $WebsitePath
        }

        # IIS server prep. Enabling site remote access
        xWebSite Petshop
        {
            Ensure = "Present"
            Name = $WebAppName
            PhysicalPath = $WebsitePath
            State = "Started"
            BindingInfo = MSFT_xWebBindingInformation
                          {
                            Protocol = "HTTP"
                            Port = $WebsitePort
                          }
        }
        
        xFireWall EnableRemoteIISAccess
        {
            Name = "PetShop_IIS_Port"
            Ensure = "Present"
            Access = "Allow"
            State ="Enabled"
            Protocol = "TCP"
            Direction = "Inbound"
            LocalPort = "$WebsitePort"
            Profile = "Any"
        }

        #Deploys PetShop Web Server in IIS
        Package InstallWebDeployTool
        {
            Ensure = "Present"
            Path  = $WebDeployURI
            ProductId = "{1A81DA24-AF0B-4406-970E-54400D6EC118}"
            Name = "Microsoft Web Deploy 3.5"
            Arguments = "/quiet"
        }  
        
        xRemoteFile PetshopSource
        {
            Uri = $WebPackageURI
            DestinationPath = $WebPackagePath
        }

        xWebPackageDeploy DeployWebPackage
        {
            Ensure = "Present"
            SourcePath = $WebPackagePath
            Destination = $WebAppName
        }

        xFindAndReplace Web2Config
        {
            FilePath = "C:\inetpub\MSPetShop\web.config"
            Pattern = "server=.\\TestDSC;"
            ReplacementString = "server=$SQLServerName\;"
        }
   }
}