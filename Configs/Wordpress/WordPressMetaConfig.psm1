# This meta configuration a system to pull configurations from a specific pull server (dscserver.contoso.com).

# Configuration to allow target nodes to reboot when the configuration requires it.
[DscLocalConfigurationManager()] 
Configuration MetaConfiguration 
{ 
        Node $AllNodes.NodeName
        {
            Settings       # on newer build use Settings instead of LoalConfigurationManager            
            { 
                ConfigurationID                = "f0f458ec-61f1-4bfe-a6a7-fb988f4e804b"
                ConfigurationMode              = 'ApplyAndAutoCorrect' 
                ConfigurationModeFrequencyMins = 15 
                RefreshFrequencyMins           = 30 
                RebootNodeIfNeeded             = $true 
            } 

            ConfigurationRepositoryWeb ResourceModuleServer
            {
                ServerURL = "https://dscserver.contoso.com:8080/PSDSCPullServer/PSDSCPullServer.svc"
            }
        }

    }
