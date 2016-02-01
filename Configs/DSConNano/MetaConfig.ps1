
[DscLocalConfigurationManager()]
Configuration MetaConfig
{
    Settings
    {
        ConfigurationModeFrequencyMins  = 45
        RebootNodeIfNeeded              = $true
        ConfigurationMode               = 'ApplyAndAutoCorrect'
        ActionAfterReboot               = 'ContinueConfiguration'
        RefreshMode                     = 'Push'
    }
}

MetaConfig -OutputPath c:\Configs\Mof\Nano -nodes localhost -Verbose

Set-DscLocalConfigurationManager -Path c:\Configs\Mof\Nano -Verbose