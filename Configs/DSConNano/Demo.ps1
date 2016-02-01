$cred = Get-Credential Administrator

$Nano1Session = New-PSSession -ComputerName Nano1 -Credential $cred
$Nano2Session = New-PSSession -ComputerName Nano2 -Credential $cred

Enter-PSSession -Session $Nano1Session

#Meta-Configuration
Get-DscLocalConfigurationManager

Set-DscLocalConfigurationManager -Path .\MOF -Verbose

#Resources
Get-DscResource

Install-Module -Name xSmbShare

#Configurations
Test-DscConfiguration -ReferenceConfiguration .\Mof\localhost.mof -Verbose

Start-DscConfiguration -Path .\Mof -Wait -Verbose