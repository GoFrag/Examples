$logFile = ".\config-process.test.txt"

Set-Content -Path $logFile  -Value "[start]"

configuration config
{
    WindowsProcess p
    {
     	Path = "c:\windows\system32\tlist.exe"
        Arguments = ""
        Ensure = "Present"
    }

    File logSuccess
    {
        DestinationPath = $logFile
        Contents = "[Success]"
        Type = "File"

        DependsOn = "[WindowsProcess]p"        
    }
}

config

start-DscConfiguration -Path .\config -Wait -Force -ComputerName localhost