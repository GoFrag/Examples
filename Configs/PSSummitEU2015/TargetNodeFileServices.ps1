
Configuration Basic
{
    Node 'Basic.FileServer'
    {
        Import-DscResource -ModuleName xSmbShare

        WindowsFeature FileAndISCSI
        {
            Ensure = 'Present'
            Name = 'File-Services'
        }

        File Software
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = '%SystemDrive%\Shares\Software'
        }

        xSmbShare Software
        {
            Ensure = 'Present'
            Name = 'Software'
            Path = '%SystemDrive%\Shares\Software'
            Description = 'Corporate Software'
            ReadAccess = "Employees"
            ChangeAccess = "Managers"
        }

        File Users
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = '%SystemDrive%\Shares\Users'
        }

        xSmbShare Users
        {
            Ensure = 'Present'
            Name = 'Users'
            Path = '%systemDrives%\Shares\Users'
            Description = 'Employee home directories.'
            ReadAccess = 'Employees'
            FolderEnumerationMode = 'AccessBased'
        }

        File Finance
        {
            Ensure            = 'Present'
            Type              = 'Directory'
            DestinationPath   = '%SystemDrive%\Shares\Finance'
        }

        xSmbShare Finance
        {
            Ensure = 'Present'
            Name = 'Finance'
            Path = '%systemDrives%\Shares\Users'
            Description = 'Employee home directories.'
            NoAccess = 'Employees'
            ChangeAccess = 'Finance'
            EncryptData = $true
        }
    }

    Node 'Basic.WebServer'
    {
        Import-DscResource -ModuleName xWebAdministration

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

Basic -OutputPath C:\Demos\PSSummitEurope2015\MOF\TargetNodes
