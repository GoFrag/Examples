$cred = Get-Credential -Message 'Enter credentail to connect to Pull Server VM.'
dir C:\Demos\PSSummitEurope2015\MOF\localhost.mof | Copy-VMFile -Name Pull -DestinationPath 'c:\Configs\localhost.mof' -CreateFullPath -FileSource Host -Force
Invoke-Command -VMName Pull -ScriptBlock {Start-DscConfiguration -Path C:\Configs\MOF\ -Wait -Verbose} -Credential $cred