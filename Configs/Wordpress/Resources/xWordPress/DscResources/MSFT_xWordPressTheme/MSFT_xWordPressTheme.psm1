data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
WordPressThemeSetError=Not able to set wordpress theme to {0}.
'@
}

Import-Module $PSScriptRoot\..\xWordPress_Common

$WordPressThemeGetURI = "{0}/wp-admin/dschelper.php?type=theme&method={1}"
$WordPressThemeURI = "$WordPressThemeGetURI&template={2}"

#copy helper file to correct location
[string] $WordPressSiteDirectory = 'c:\inetpub\Wordpress' #FOR DEMO ONLY:This should not be hard coded.

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TemplateName,

        [parameter(Mandatory = $true)]
		[System.String]
		$URI
	)

    New-WordPressPHPHelper $WordPressSiteDirectory

    # Set the default to 'Absent'
    $Ensure = 'Absent'

    Write-Debug -Message "Connecting to URI: ($WordPressThemeGetURI -f $Uri.TrimEnd('/'),'get')"
    $result = Invoke-WebRequest -UseBasicParsing -Uri ($WordPressThemeGetURI -f $Uri.TrimEnd('/'),'get') -Verbose:$false

    if($result.StatusCode -eq 200 -and ($result.Content.Trim('ï»¿   ') -eq $TemplateName))
    {
		    $Ensure = 'Present'
    }
        
    return @{
                TemplateName = $TemplateName
                Uri          = $URI
                Ensure       = $Ensure
            }
}

function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TemplateName,

        [parameter(Mandatory = $true)]
		[System.String]
		$URI
	)

    New-WordPressPHPHelper $WordPressSiteDirectory

    Write-Verbose -Message "Setting the theme $TemplateName ..."        
    Write-Debug -Message "Connecting to URI: ($WordPressThemeURI -f $Uri.TrimEnd('/'),'set',$TemplateName.ToLower())"
    $result = Invoke-WebRequest -UseBasicParsing -Uri ($WordPressThemeURI -f $Uri.TrimEnd('/'),'set',$TemplateName.ToLower()) -Verbose:$false

    # If the status code of the request is not 200, there is error
    if ($result.StatusCode -ne 200)
    {
        New-TerminatingError -errorId ThemeSetFailed -errorMessage ($($LocalizedData.WordPressThemeSetError) -f $TemplateName) -errorCategory InvalidResult
    }
    else
    {
            Write-Verbose -Message "Theme $TemplateName is now set"        
    }
}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TemplateName,

        [parameter(Mandatory = $true)]
		[System.String]
		$URI
	)

    New-WordPressPHPHelper $WordPressSiteDirectory

    # Check the current state of the theme
    Write-Verbose -Message "Checking if theme $TemplateName is set ..."
    Write-Debug -Message "Connecting to URI: ($WordPressThemeURI -f $Uri.TrimEnd('/'),'test',$TemplateName.ToLower())"
    $result = Invoke-WebRequest -UseBasicParsing -Uri ($WordPressThemeURI -f $Uri.TrimEnd('/'),'test',$TemplateName.ToLower()) -Verbose:$false
    
    # If the status code = 200, the request succeeded
    if($result.StatusCode -eq 200)
    {
        # Check for content to be true, after trimming 
        if($result.Content.Trim('ï»¿   ') -eq 'True')
        {
            Write-Verbose -Message "Theme $TemplateName is set"
            return $true
        }
        else
        {
            Write-Verbose -Message "Theme $TemplateName is not set"
            return $false
        }
    }

    # This code path is not expected, so something is broken
    else
    {
        Throw "Unexpected response $($result.StatusCode)"
    }
}

Export-ModuleMember -Function *-TargetResource