$script:testLogLocation = "$env:PUBLIC\DSC\Test\ProviderLogs"
$name = $myInvocation.MyCommand.Name
$script:resourceName  = $name.SubString(0,$name.LastIndexOf('.'))

function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Id
	)

	Write-Verbose "Getting current configuration of the system for id: $Id processing."

	$fileName = "Set_{0}.txt" -f $Id
	$log  = cat "$testLogLocation\$resourceName\$fileName"
	
	$returnValue = @{
		Id = $Id
		TestLogMessage = $log.split('#')[1].trim()
		LogTime = $log.split('#')[0].trim()
	}

	$returnValue

}


function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Id,

		[System.String]
		$TestLogMessage,

		[System.String]
		$LogTime
	)

	
	$fileName = "Set_{0}.txt" -f $Id
	New-Item -Type Directory  "$testLogLocation\$resourceName" -ea SilentlyContinue
	New-Item -Type File   "$testLogLocation\$resourceName\$fileName"  -ea SilentlyContinue
	$log = "{0}`t#{1}" -f $LogTime, $TestLogMessage 
	$log > "$testLogLocation\$resourceName\$fileName" 
	Write-Verbose "Applying configuration using the resource name $resourceName "
}


function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Id,

		[System.String]
		$TestLogMessage,

		[System.String]
		$LogTime
	)

	$fileName = "Set_{0}.txt" -f $Id
	Write-Verbose "running TEST method of the resource: $resourceName and id: $id"
	
	return (Test-path "$testLogLocation\$resourceName\$fileName")
}



