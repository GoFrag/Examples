
$configName = "config"
$H = Get-Location

$script:TestConfigFolder = "$H\$configName"

if (Test-Path $TestConfigFolder -ErrorAction Ignore) {
    Remove-Item -Path $TestConfigFolder -Force -Recurse
}

New-Item -Path $TestConfigFolder -ItemType Directory -Force

$logFile = Join-Path -Path $TestConfigFolder -ChildPath "config-demo.test.txt"

Set-Content -Path $logFile  -Value "[start]"


Write-Host $home

configuration config
{
    Import-DscResource -Module xSmbShare
    Import-DscResource -Module PSDesiredStateConfiguration


    File f
    {
        DestinationPath = "$H\FileTest.txt"
        Contents = "This is Test"
        Type = "File"
        Ensure = "Present"
    }

    Log l
    {
        Message = "Hello!"

        DependsOn = "[File]f"
    }

    xSmbShare share
    {
     	Ensure = "Present"
        Name   = "Dsc4Nano"
        Path = "$H";
        FullAccess = "everyone"  

        DependsOn = "[Log]l"
    }


    File logSuccess
    {
        DestinationPath = $logFile
        Contents = "[Success]"
        Type = "File"

        DependsOn = "[xSmbShare]share"
    }
}

config

try {
   start-DscConfiguration -Path $TestConfigFolder -Wait -Force -ComputerName localhost
}
catch {
    $_;    
}

if ("[Success]" -ne (Get-Content $logFile)) {
    Write-Error "Test failed"
}
else {
    Write-Host "Test Success!" -ForegroundColor Green
}

Get-Content $logFile


