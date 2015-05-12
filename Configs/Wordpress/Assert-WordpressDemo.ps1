# This configuration configures a Basic WordPress Site
# It requires xPhp, xMySql, xWordPress, xWebAdministration, xSystemSecurity, and xPSDesiredStateConfiguration
# Please review the note about the FQDN variable and
# about the URLs, they may need to be updated.
$ConfigurationData = Join-Path $PSScriptRoot "WordpressDemo.psd1"
$ConfigurationScript = Join-Path $PSScriptRoot "WordpressConfig.psm1"
$MetaConfigurationScript = Join-Path $PSScriptRoot "WordpressMetaConfig.psm1"
#$RootAuthorityCertPath = dir (join-path $PSScriptRoot "certs") | where Extension -eq ".cer" | where Name -Like "*root authority*"
#$RootAuthorityThumbprint =  ((New-Object System.Security.Cryptography.X509Certificates.X509Certificate2).import($RootAuthorityCertPath)).Thumbprint
#$RootAuthorityCertBinaryStream = [System.IO.File]::ReadAllBytes($RootAuthorityCertPath.fullname)

#region Generate CliXML files for WordPress and DB accounts in the script root folder on the machine where configuration will be processed
# Example: get-credential | export-clixml AccountWp.xml
#          get-credential | export-clixml AccountDb.xml
#          get-credential | export-clixml AccountDbRoot.xml

$WordpressAccount = Import-Clixml (join-path $PSScriptRoot "AccountWp.xml")
$WordpressDatabaseAccount = Import-Clixml (join-path $PSScriptRoot "AccountDb.xml")
$WordpressDatabaseRoot = Import-Clixml (join-path $PSScriptRoot "AccountDbRoot.xml")
$Cred = Import-Clixml (join-path $PSScriptRoot "TestAdmin.xml")
#endregion

# Import the WordPress Meta-configuation
Import-Module $MetaConfigurationScript

# Import the Wordpress configuration
Import-Module $ConfigurationScript

$outputFolder = "c:\Configs\WordPressConfig"
MetaConfiguration -OutputPath $outputFolder -ConfigurationData "$configurationData"
WordpressWebsiteConfig -OutputPath $outputFolder -ConfigurationData "$configurationData" -WordpressAccount $WordpressAccount -WordpressDatabaseAccount $WordpressDatabaseAccount -wordpressDatabaseRoot $WordpressDatabaseRoot

Set-DscLocalConfigurationManager -path $outputFolder -Credential $Cred -verbose

Start-DscConfiguration -path $outputFolder -Credential $Cred -Wait -Verbose 
