
Configuration Meta
{
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            RefreshMode = 'Pull'
            ConfigurationID = $Node.NodeName
            DownloadManagerName = 'WebDownloadManager'
            DownloadManagerCustomData = @{ServerUrl='http://corp.fabricam.com/PSDSCPullServer.svc';AllowUnsecureConnection = "True"}
        }
    }
}

Meta -ConfigurationData '.\v1 ConfigData.psd1' -OutputPath 'C:\Demos\PSSummitEurope2015\MOF\V1' -Verbose