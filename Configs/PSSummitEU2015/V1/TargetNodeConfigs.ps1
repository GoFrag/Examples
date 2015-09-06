Configuration Basic
{
    Import-DscResource -ModuleName xSmbShare
    Import-DscResource -ModuleName xWebAdministration

    #File Server Config
    Node $AllNodes.Where($_.Role -eq 'FileServer').NodeName
    {
        WindowsFeature FileAndISCSI
        {
            Ensure = 'Present'
            Name = 'File-Services'
        }

        File Software
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = 'c:\Shares\Software'
        }

        xSmbShare Software
        {
            Ensure = 'Present'
            Name = 'Software'
            Path = 'c:\Shares\Software'
            Description = 'Corporate Software'
            ReadAccess = "Employees"
            ChangeAccess = "Managers"
        }

        File Users
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = 'c:\Shares\Users'
        }

        xSmbShare Users
        {
            Ensure = 'Present'
            Name = 'Users'
            Path = 'c:\Shares\Users'
            Description = 'Employee home directories.'
            ReadAccess = 'Employees'
            FolderEnumerationMode = 'AccessBased'
        }

        File Finance
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = 'c:\Shares\Finance'
        }

        xSmbShare Finance
        {
            Ensure = 'Present'
            Name = 'Finance'
            Path = 'c:\Shares\Finance'
            Description = 'Finance department documents.'
            NoAccess = 'Employees'
            ChangeAccess = 'Finance'
            EncryptData = $true
        }
    }

    # WebServer config
    Node $AllNodes.Where($_.Role -eq 'WebFrontEndServer').NodeName
    {
        WindowsFeature WebServer
        {
            Ensure = 'Present'
            Name = 'Web-Server'
        }

        File PublicSite
        {
            Ensure = 'Present'
            Type = 'Directory'
            DestinationPath = 'c:\inetpub\fabricam'
        }

        xWebAppPool FabricamPublic
        {
            Ensure = 'Present'
            Name = 'Public'
            State = 'Started'
        }

        xWebsite FabricamPublic
        {
            Ensure = 'Present'
            Name = 'Fabricam.com'
            PhysicalPath = 'c:\inetpub\fabricam'
            State = 'Started'
            ApplicationPool = 'Public'
            BindingInfo = MSFT_xWebBindingInformation
                             {
                               Protocol = "HTTP"
                               Port = 8080
                             }
        }
    }
}

Basic-ConfigurationData '.\v1 ConfigData.psd1' -OutputPath 'C:\Demos\PSSummitEurope2015\MOF\V1' -Verbose