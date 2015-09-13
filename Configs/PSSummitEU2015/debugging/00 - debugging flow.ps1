cd C:\Git\Examples\Configs\PSSummitEU2015\debugging

# Break into running script
# '.\01 - LongRunningScript.ps1'

#Edit and debug remote script
Enter-PSSession PSDemo45
cd C:\DemoScripts\
PSEdit .\MyScript.ps1
exit

#Debug job
# job needs to reference full path since job creates new session which will have default path
Start-Job {& 'C:\Git\Examples\Configs\PSSummitEU2015\DevOps\01 - LongRunningScript.ps1'} -Name "Debug"
Get-Job
Debug-job -Name Debug
Detach
Quit

#Debug process / runspace
#Launch c:\MyScript.ps1 in PS console
$ProcessId = (Get-PSHostProcessInfo | where {$_.ProcessName -eq 'Powershell'}).ProcessId
Enter-PSHostProcess -Id $ProcessId
$RunspaceId = (Get-Runspace | where {$_.Name -notcontains "RemoteHost"}).Id
Debug-Runspace -Id $RunspaceId

#Debug DSC Configuration
Enter-PSSession corp.fabricam.com
Enable-DscDebug -BreakAll
& 'c:\configs\03 - Config.ps1'

