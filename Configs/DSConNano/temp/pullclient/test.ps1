$serverURL = "https://10.217.110.246:8443/PSDSCPullServer/PSDSCPullserver.svc"
$registrationKey = "140a952b-b9d6-406b-b416-e0f759c9c0e4"
$configName = "webrole"
[DscLocalConfigurationManager()]
Configuration RegistrationMetaConfig
{
        Settings
        {
            RefreshFrequencyMins = 30;
            RefreshMode = "PULL";
            ConfigurationMode =”ApplyAndAutocorrect“;
            AllowModuleOverwrite  = $true;
            RebootNodeIfNeeded = $true;
            ConfigurationModeFrequencyMins = 60;
        }
        ConfigurationRepositoryWeb ConfigurationManager
        {
            ServerURL =  $serverURL
            AllowUnsecureConnection = $true     
            RegistrationKey = $registrationKey     
            ConfigurationNames = @($configName)
        }     
        ResourceRepositoryWeb ResourceManager
        {
            ServerUrL = $serverURL
            AllowUnsecureConnection  = $true
            RegistrationKey = $registrationKey 
        }
  
        ReportServerWeb ReportManager
        {
            ServerUrL = $serverURL
            AllowUnsecureConnection  = $true
            RegistrationKey = $registrationKey 
        }
   
}

RegistrationMetaConfig