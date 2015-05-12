#region Generate CliXML files for WordPress and DB accounts in the script root folder on the machine where configuration will be processed
# Example: get-credential | export-clixml AccountWp.xml
#          get-credential | export-clixml AccountDb.xml
#          get-credential | export-clixml AccountDbRoot.xml

$WordpressAccount = Import-Clixml (join-path $PSScriptRoot "AccountWp.xml")
$WordpressDatabaseAccount = Import-Clixml (join-path $PSScriptRoot "AccountDb.xml")
$WordpressDatabaseRoot = Import-Clixml (join-path $PSScriptRoot "AccountDbRoot.xml")
#endregion

#Set up the azure subscription that will be used to deploy the DSC configuration
Import-AzurePublishSettingsFile -PublishSettingsFile 'C:\Configs\Azure\AutomationTeam-CI Automation Demo-10-16-2014-credentials.publishsettings' -Verbose
Set-AzureSubscription -SubscriptionName 'CI Automation Demo' -CurrentStorageAccountName 'dscprod' -Verbose
Select-AzureSubscription -SubscriptionName 'CI Automation Demo' -Verbose

#Zip up the DSC configuration and related files and publish to azure blob store
Publish-AzureVMDscConfiguration -ConfigurationPath $PSScriptRoot\WordpressConfig.psm1 -Force -Verbose 

#update an existing Azure VM using the DSC configuration published to azure blob store
$vm = Get-AzureVM -Name Fourthcoffee -ServiceName fourthcoffee -Verbose
$vm = Set-AzureVMDscExtension -VM $vm -ConfigurationArchive WordpressConfig.psm1.zip -ConfigurationName WordpressWebsiteConfig -ConfigurationDataPath $PSScriptRoot\WordpressDemoInAzure.psd1 -ConfigurationArgument @{WordpressAccount=$WordpressAccount; WordpressDatabaseAccount=$WordpressDatabaseAccount; WordpressDatabaseRoot=$WordpressDatabaseRoot}  -Verbose
$vm | Update-AzureVM -Verbose
