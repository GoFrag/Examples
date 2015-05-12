###################################################
#### Configure Azure VMs with Azure Automation ####
###################################################
Switch-AzureMode AzureResourceManager
Add-AzureAccount 
Select-AzureSubscription -SubscriptionName "CI Automation Demo"
Set-AzureSubscription -SubscriptionName "CI Automation Demo" -CurrentStorageAccountName "petshopdata2"
$myResourceGroup = get-AzureResourceGroup -Name "petshopdemo"
$myAutomationAccount = $myResourceGroup | get-AzureAutomationAccount -Name "petshop"

### Get Azure Automation Account Registration information
$myRegInfo = $myAutomationAccount | Get-AzureAutomationRegistrationInfo
$myRegInfo.PrimaryKey
$myRegInfo.Endpoint

#### Import custom resources
$myAutomationAccount | New-AzureAutomationModule -Name "xFileContent" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xFileContent.zip"
$myAutomationAccount | New-AzureAutomationModule -Name "xNetworking" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xNetworking.zip"
$myAutomationAccount | New-AzureAutomationModule -Name "xPSDesiredStateConfiguration" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xPSDesiredStateConfiguration.zip"
$myAutomationAccount | New-AzureAutomationModule -Name "xSqlPs" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xSqlPs.zip" -Verbose
$myAutomationAccount | New-AzureAutomationModule -Name "xWebAdministration" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xWebAdministration.zip"
$myAutomationAccount | New-AzureAutomationModule -Name "xWebDeploy" -ContentLink "https://petshopdata2.blob.core.windows.net/dscresources/xWebDeploy.zip"

#### Import configuration script
$myConfig = $myAutomationAccount | Import-AzureAutomationDscConfiguration -SourcePath 'c:\examples\configs\petshop - OaaS\PetShopWebApp.ps1' -Description "Configuration to deploy petshop sample web application to one or two servers." -Published -force
$myConfig = Get-AzureAutomationDscConfiguration  -ResourceGroupName "petshopdemo" -AutomationAccountName "petshop" -Name "PetShopWebApp"

#### Compile the configuration script to generate Node Configurations
$myCompilationJob = $myConfig | Start-AzureAutomationDscCompilationJob -Parameters @{SQLUserName="OaaS";SQLPassword="pass@word1";SQLServerName="IgniteDemoSQL"}
$myCompilationJob | Get-AzureAutomationDscCompilationJob 

#### Get Agent IDs and Show VMs current configuration
$myAutomationAccount | Get-AzureAutomationDscNode -Name IgniteDemoSQL
$myAutomationAccount | Get-AzureAutomationDscNode -Name IgniteDemoIIS

#### Get list of Node configurations
$myAutomationAccount | Get-AzureAutomationDscNodeConfiguration

#### Link nodes to node configurations
$SQLNode = $myAutomationAccount |  Set-AzureAutomationDscNode -NodeConfigurationName "PetShopWebApp.SQL" -Id  "" ##Add ID
$IISNode = $myAutomationAccount |  Set-AzureAutomationDscNode -NodeConfigurationName "PetShopWebApp.IIS" -Id  "" ##Add ID

#### Verify that node configuration is assigned
$myAutomationAccount | Get-AzureAutomationDscNode

#### Force pull of configuration on target nodes
Update-DscConfiguration -Wait -Verbose

##################################
#### Onboarding non-Azure VMs ####
##################################
#### Download meta-configuration
$myAutomationAccount | Get-AzureAutomationDscOnboardingMetaconfig -OutputFolder C:\temp\Petshop

#### Apply meta-config to local VM and register with Azure automation 
Set-DscLocalConfigurationManager -Path .\ -Verbose
Update-DscConfiguration -Wait -Verbose

#### Assign SQL config to Local VM
$myAutomationAccount | Get-AzureAutomationDscNode
$Node2 = $myAutomationAccount | Set-AzureAutomationDscNode -NodeConfigurationName "PetShopWebApp.SQL" -Id "6f7424da-f4fe-11e4-80ce-00155d3dc00a"

#### Force pull of configuration on local VM
Update-DscConfiguration -Wait -Verbose

#### Get Reporting information
$myAutomationAccount | Get-AzureAutomationDscNode
$myAutomationAccount | Get-AzureAutomationDscNodeReport -NodeId "6f7424da-f4fe-11e4-80ce-00155d3dc00a" ##Add ID
$myAutomationAccount | Export-AzureAutomationDscNodeReportContent -NodeId "" -ReportId "" -OutputFolder 'C:\temp\Petshop'





#region Reference commands
Register-AzureProvider -ProviderNamespace "Microsoft.Automation"
Register-AzureProviderFeature -FeatureName dsc -ProviderNamespace "Microsoft.Automation" -Force
New-AzureResourceGroup -Name "petshopdemo" -Location "japaneast" -Force
$myResourceGroup = get-AzureResourceGroup -Name "petshopdemo"
$myResourceGroup | New-AzureAutomationAccount -Name "petshop" -Location "japaneast" 
$myAutomationAccount = $myResourceGroup | get-AzureAutomationAccount -Name "petshop"
$myAutomationAccount
#### Import configuration script
$myConfig = $myAutomationAccount | Import-AzureAutomationDscConfiguration -SourcePath 'e:\examples\configs\petshop - OaaS\PetShopWebApp.ps1' -Description "Configuration to deploy petshop sample web application to one or two servers." -Published -force
$myConfig = Get-AzureAutomationDscConfiguration  -ResourceGroupName "petshopdemo" -AutomationAccountName "petshop" -Name "PetShopWebApp"
$myConfig

#### Check state of module upload
$myAutomationAccount | Get-AzureAutomationModule -Name xFileContent
$myAutomationAccount | Get-AzureAutomationModule -Name xNetworking
$myAutomationAccount | Get-AzureAutomationModule -Name xPSDesiredStateConfiguration
$myAutomationAccount | Get-AzureAutomationModule -Name xSqlPs
$myAutomationAccount | Get-AzureAutomationModule -Name xWebAdministration
$myAutomationAccount | Get-AzureAutomationModule -Name xWebDeploy

####

$myCompilationJob = $myConfig | Start-AzureAutomationDscCompilationJob -Parameters @{SQLUserName=$User;SQLPassword=$Password;SQLServerName=$ServerName}
$myCompilationJobStatus = $myCompilationJob | Get-AzureAutomationDscCompilationJob 
$myCompilationJobStatus

$myRegistration  = $myAutomationAccount | Get-AzureAutomationRegistrationInfo
write-output $myRegistration.Endpoint

$myMetaMof = $myAutomationAccount | Get-AzureAutomationDscOnboardingMetaconfig -OutputFolder "\\dcmstor01\SCX\Team\ggopal\SampleOutput" -ComputerName "localhost" -Force
$myMetaMof

Set-DscLocalConfigurationManager -Path "\\dcmstor01\SCX\Team\ggopal\SampleOutput\DscMetaConfigs" -ComputerName "localhost"
$myNode = Get-DscLocalConfigurationManager



Set-AzureAutomationDscNode -NodeConfigurationName "helloworldconfig.localhost" -Id $myNode.AgentId -ResourceGroupName $myAutomationAccount.ResourceGroupName -AutomationAccountName $myAutomationAccount.AutomationAccountName -Force

Get-DscConfiguration

#Assign nodeConfigs to Nodes
$myAutomationAccount | Set-AzureAutomationDscNode

#Get meta-config
$myAutomationAccount | Get-AzureAutomationDscOnboardingMetaconfig 

#endregion Reference commands