[DscLocalConfigurationManager()]
configuration metaconfig
{
    Settings
    {
        RefreshMode = "Push"
    }
}

metaconfig -OutputPath C:\examples\MOF\meta

Set-DscLocalConfigurationManager -Path C:\examples\MOF\meta -Verbose