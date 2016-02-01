Set-Content -Value "Test.Providers.Registry.Failed" -Path c:\dscTests.txt

configuration config
{
    Registry r
    {
     	Key = "HKEY_LOCAL_MACHINE\SOFTWARE\ExampleKey"
        ValueName = "TestKey"
        ValueData = "TestNano"   
    }
    
    File log
    {
       DestinationPath = "C:\dscTests.txt"
       Contents = "Test.Providers.Registry.Succeed"
       Type = "File"

       DependsOn = "[Registry]r"
    }
}

config
