
Configuration Basic
{
    Node 'Basic.FileServer'
    {
        WindowsFeature FileAndISCSI
        {
            Ensure = 'Present'
            Name = 'File-Services'
        }
    }
}

Basic -OutputPath C:\Configs\MOF\TargetNodes
