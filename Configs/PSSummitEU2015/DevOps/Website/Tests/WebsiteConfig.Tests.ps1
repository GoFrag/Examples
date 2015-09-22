﻿####################################################################
# Unit tests for WebsiteConfig
#
# Unit tests content of DSC configuration as well as the MOF output.
####################################################################

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$parent = Split-Path -Parent $here
$sut = ($MyInvocation.MyCommand.ToString()).Replace(".Tests.", ".")
. $(Join-Path $parent $sut)

if (! (Get-Module xWebAdministration -ListAvailable))
{
    Install-Module -Name xWebAdministration -Force
}

Describe "Website Configuration" {
      
    Context "Configuration Script"{
        
        It "Should be a DSC configuration script" {
            (Get-Command Website).CommandType | Should be "Configuration"
        }

        It "Should not be a DSC Meta-configuration" {
            (Get-Command website).IsMetaConfiguration | Should Not be $true
        }
        
        It "Should require the source path parameter" {
            (Get-Command Website).Parameters["SourcePath"].Attributes.Mandatory | Should be $true
        }

        It "Should fail when an invalid source path is provided" {
            website -SourcePath "This is not a path" | should Throw
        }

        It "Should include the following 3 parameters: 'SourcePath','WebsiteName','DestinationRootPath' " {
            (Get-Command Website).Parameters["SourcePath","WebsiteName","DestinationRootPath"].ToString() | Should not BeNullOrEmpty 
        }

        It "Should use the xWebsite DSC resource" {
            (Get-Command Website).Definition | Should Match "xWebsite"
        }
    }

    Context "Node Configuration" {
        $OutputPath = "TestDrive:\"
        
        It "Should generate a single mof file." {
            Website -OutputPath $OutputPath -SourcePath "\\Server1\Configs\"
            (Get-ChildItem -Path $OutputPath -File -Filter "*.mof" -Recurse ).count | Should be 1
        }

        It "Should generate a mof file with the name 'Website.FourthCoffee'." {
            Website -OutputPath $OutputPath -SourcePath "\\Server1\Configs\"
            Join-Path $OutputPath "Website.FourthCoffee.mof" | Should Exist
        }

        It "Should be a valid DSC MOF document"{
            Website -OutputPath $OutputPath -SourcePath "\\Server1\Configs\"
            mofcomp -check "$OutputPath\Website.FourthCoffee.mof" | Select-String "compiler returned error" | Should BeNullOrEmpty
        }

        It "Should generate a new version (2.0) mof document." {
            Website -OutputPath $OutputPath -SourcePath "\\Server1\Configs\"
            Join-Path $OutputPath "Website.FourthCoffee.mof" | Should Contain "Version=`"2.0.0`""
        }

        It "Should create a mof that has a website named 'BustersBuns'." {
            Website -OutputPath $OutputPath -SourcePath "\\Server1\Configs\" -WebSiteName "BustersBuns"
            Join-Path $OutputPath "Website.BustersBuns.mof" | Should Contain "Name = `"BustersBuns`";"
        }

        #Clean up TestDrive between each test
        AfterEach {
            Remove-Item TestDrive:\* -Recurse
        }

    }
}