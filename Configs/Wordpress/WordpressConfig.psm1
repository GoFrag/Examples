#region Helper Configurations
configuration xRemoteThemesAndPluginFiles
{
    param(
        [string[]]
        $FileNames,

        [string]
        $Uri,

        [string]
        $WordpressPath,

        [string]
        [ValidateSet("plugins", "themes")]
        $Type = "plugins"
    )
    Import-DscResource -module xPsDesiredStateConfiguration
    
    $DestinationPath = "C:\Users\Public\Downloads"

    foreach ($fileName in $fileNames)
    {
        xRemoteFile $fileName
        {
            Uri               = "$Uri/$fileName"
            DestinationPath   = join-path $DestinationPath $fileName
        }

        Archive $fileName
        {
            Ensure            = "Present"
            Path              = join-path $DestinationPath $fileName
            Destination       = "$WordpressPath\wp-content\$type"

            Dependson         = "[xRemoteFile]$fileName"
        }
    }
}

configuration enabledWordpressPlugins
{
    param(
        [string[]]
        $Names,

        [string]
        $Uri
    )

    Import-DscResource -module xWordPress

    foreach ($Name in $Names)
    {
        xWordpressPlugin $Name
        {
            Name       = $Name
            URI        = $Uri
            State      = "Enabled"
        }
    }
}

#endregion


# This configuration configures a WordPress Site
# It requires xPhp, xMySql, xWordPress, xWebAdministration, xSystemSecurity, and xPSDesiredStateConfiguration

Configuration WordpressWebsiteConfig
{
    param(
        [parameter(Mandatory = $true)]
		[pscredential]
        $WordpressAccount,
        
        [parameter(Mandatory = $true)]
		[pscredential]
        $WordpressDatabaseAccount,
        
        [parameter(Mandatory = $true)]
		[pscredential]
        $WordpressDatabaseRoot
    )

    #region Import composite resources
    Import-DscResource -module xMySql 
    Import-DscResource -module xWordPress
    Import-DscResource -module xPhp
    Import-DscResource -module xSystemSecurity
    Import-DscResource -module xWebAdministration
    Import-DscResource -module xPsDesiredStateConfiguration
    import-DscResource -module xDACL
    #endregion

    node $Allnodes.Where{$_.Role -contains "Wordpress"}.Nodename
    {
        # Make sure MySql is installed with a WordPress database
        xMySqlProvision mySql
        {
            ServiceName    = $Node.MySqlServiceName
            DownloadURI    = $Node.MySqlDownloadURI
            RootCredential = $WordpressDatabaseRoot
            DatabaseName   = $Node.DatabaseName
            UserCredential = $WordpressDatabaseAccount
            ProductId      = $Node.MySqlProductID
            ProductName    = $Node.MySqlProductName
        }

        # Make sure PHP is installed in IIS
        xPhpProvision  php
        {
            InstallMySqlExt         = $true
            DownloadUri             = $Node.Php.DownloadURI
            DestinationPath         = $Node.Php.Path
            ConfigurationPath       = $Node.Php.TemplatePath
            Vc2012RedistDownloadUri = $Node.Php.Vc2012RedistUri
        }
        
        xwebsite DefaultSite
        {
            Ensure                   = "Present"
            Name                     = "Default Web Site"
            PhysicalPath             = "c:\inetpub\wwwroot"
            State                    = "Stopped"
        }
         
        # Make sure the IIS site for WordPress is created
        xIisWordPressSite iisWordPressSite
        {
            DbUser                  = $WordpressDatabaseAccount
            DatabaseName            = $Node.DatabaseName
            DownloadUri             = $Node.Wordpress.DownloadURI
            WordPressIisSiteName    = $Node.Wordpress.IisSiteName
            WordPressSiteDirectory  = $Node.Wordpress.Path
            DbHostName              = $Node.Wordpress.DbHostName
        }

        # Make sure the WordPress site is present
        xWordPressSite WordPressSite
        {
            Uri                     = $Node.WordPress.Uri
            Title                   = $Node.WordPress.Title
            AdministratorCredential = $WordpressAccount
            AdministratorEmail      = $Node.WordPress.Email
            DependsOn               = "[xIisWordPressSite]iisWordPressSite"
        } 

        xRemoteThemesAndPluginFiles ThemeArchive
        {
            fileNames         = "storefront-paper.1.1.1.zip"
            Uri               = $Node.DownloadRootURI
            WordpressPath     = $Node.WordPress.Path
            type              = "themes"
            DependsOn         = "[xWordPressSite]WordPressSite"
        }

        xWordpressTheme LatestTheme
        {
            TemplateName      = "storefront-paper"
            URI               = $Node.WordPress.Uri
            DependsOn         = "[xRemoteThemesAndPluginFiles]ThemeArchive"
        }

        # Configure Plugins
        xRemoteThemesAndPluginFiles PluginArchives
        {
            fileNames        = "easy-fancybox.1.5.6.zip", "smart-slider-2.2.3.11.zip", "wp-e-commerce.3.8.14.3.zip"
            Uri              = $Node.DownloadRootURI
            WordpressPath    = $Node.WordPress.Path
        }

        enabledWordpressPlugins fourthCoffee
        {
            Names            = "easy-fancybox", "smart-slider-2", "wp-e-commerce"
            Uri              = $Node.WordPress.Uri
            DependsOn        = "[xRemoteThemesAndPluginFiles]PluginArchives"
        }

        #Set permissions on Wordpress website folder
        xDirectoryDacl WordpressDirectory
        {
            Action = "Allow"
            DirectoryName = $Node.WordPress.Path
            AccountName = "IIS_IUSRS"
            Permission = "Modify"
        }

        # Add test data only in test environment
        if ($Node.DeploymentStage -eq "Test")
        {
            xRemoteFile TestDataImageArchive
            {
                Uri              = "$($Node.DownloadRootURI)/TestDataImages.zip"
                DestinationPath  = "C:\Users\Public\Downloads\TestDataImages.zip"
            }

            Archive TestDataImages
            {
                Ensure        = "Present"
                Path          = "C:\Users\Public\Downloads\TestDataImages.zip"
                Destination   = "c:\inetpub\wordpress\wp-content\uploads\2014\10"
                DependsOn     = "[xRemoteFile]TestDataImageArchive"
            }

            xRemoteFile SQLBackupFile
            {
                Uri               = "$($Node.DownloadRootURI)/fourthcoffee_backup.sql.txt"
                DestinationPath   = "$($Node.DownloadDestination)\fourthcoffee_backup.sql"
                DependsOn         = "[xMySqlProvision]mySql"
            }

            Script testData
            {
                SetScript = { pushd "C:\Program Files\MySQL\MySQL Server 5.6\bin\" ; cmd.exe /c "mysql.exe -w -uroot -ppass@word1 wordpress < C:\Users\Public\Downloads\fourthcoffee_backup.sql" 2> $null; out-file "C:\Users\Public\Downloads\10-22-2014-1200.txt"}
                testScript = {if((dir "C:\Users\Public\Downloads\10-22-2014-1200.txt" -ErrorAction SilentlyContinue).Exists){return $true}else{return $false}}
                getScript = {return "Script process successfully."}
                DependsOn = "[xRemoteFile]SQLBackupFile"
            }
        }
        
    }
    
}