$cred = Get-Credential -Message 'Enter credentail to connect to target Server VM.'
dir C:\Demos\PSSummitEurope2015\MOF\TargetNodes\localhost.meta.mof | Copy-VMFile -Name Server -DestinationPath 'c:\Configs\MOF\localhost.meta.mof' -CreateFullPath -FileSource Host -Force
Invoke-Command -VMName Server -ScriptBlock {Set-DscLocalConfigurationManager -Path C:\Configs\MOF\ -Verbose} -Credential $cred