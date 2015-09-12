##
## Function to start a given script file in a local or 
## remote runspace, and return runspace along with 
## the PowerShell object running the script and async
## object to get results.
##
function Start-ScriptFileInRunspace
{
    [cmdletbinding()]

    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [string] $RunspaceName = "TestRunspace",

        [switch] $EnableDebugging,

        [switch] $RemoteRunspace,

        [PSCredential] $Credential
    )

    $ResolvedPath = Resolve-Path $FilePath

    #
    # Create the runspace
    #
    [Runspace] $runspace = $null
    if ($RemoteRunspace.IsPresent)
    {
        $connectionInfo = [System.Management.Automation.Runspaces.WSManConnectionInfo]::new()
        $connectionInfo.Credential = $Credential

        $typeTable = [System.Management.Automation.Runspaces.TypeTable]::LoadDefaultTypeFiles()

        $runspace = [runspacefactory]::CreateRunspace($connectionInfo, $host, $typeTable)
    }
    else
    {
        $runspace = [runspacefactory]::CreateRunspace($host)
    }
    $runspace.Name = $RunspaceName
    $runspace.Open()

    if ($EnableDebugging)
    {
        Enable-RunspaceDebug $runspace -BreakAll
    }

    #
    # Create the PowerShell object to run the script file
    #
    [PowerShell] $powerShell = [PowerShell]::Create()
    $powerShell.Runspace = $runspace
    $null = $powerShell.AddScript($ResolvedPath.Path)
    
    #
    # Start the script running in the runspace
    #
    $asyncResult = $powerShell.BeginInvoke()

    #
    # Return running information
    #
    return @{
        Runspace=$runspace;
        PowerShell=$powerShell;
        AsyncResult=$asyncResult
    }
}
