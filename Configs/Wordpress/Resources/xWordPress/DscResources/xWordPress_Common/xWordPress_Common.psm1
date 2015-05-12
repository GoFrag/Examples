data LocalizedData
{
    # culture="en-US"
    ConvertFrom-StringData @'
SmoFxInstallationError=Please ensure that Smo is installed.
'@
}

$Filename = 'dschelper.php'
Set-Variable Filename -option ReadOnly

function New-WordPressPHPHelper
{
    param( 
        [Parameter(Mandatory = $true)]
        [string] $WordpressPath
    )

    $SourceFile = join-path $PSScriptRoot $Filename
    $WpAdminPath = Join-Path $WordpressPath "wp-admin"
    $DestinationFile = join-path $WpAdminPath $Filename
    $CopyToDestination = $false

    if(Test-Path $DestinationFile)
    {
        #Compare of source and destination. Copy if different.
        
        $SourceHash = Get-FileHash $SourceFile
        $DestinationHash = Get-FileHash $DestinationFile

        if($SourceHash.Hash -ne $DestinationHash.Hash)
        {
            Write-Debug "DSC PHP helper file '$DestinationFile' is NOT the same as the source file '$SourceFile' and will be overwritten."
            $CopyToDestination = $true
        }
        else
        {
            Write-Debug "DSC PHP helper file '$DestinationFile' is the same as the source file '$SourceFile'."
        }
    }
    else
    {
        Write-Debug "DSC PHP helper file '$DestinationFile' does not exist. Source file '$SourceFile' will be copied to this location."
        $CopyToDestination = $true
    }

    if ($CopyToDestination)
    {
        copy $SourceFile $DestinationFile -Force
        Write-Verbose "Successfully copied DSC PHP helper file."
    }
    else
    {
        Write-Verbose "DSC PHP helper file already exists."
    }

    
}

function Remove-WordPressPHPHelper
{
    param( 
        [Parameter(Mandatory = $true)]
        [string] $WordpressPath
    )
    $WpAdminPath = Join-Path $WordpressPath "wp-admin"

    Remove-Item -Path (Join-Path $WpAdminPath $Filename) -Force -ErrorAction SilentlyContinue

    Write-Verbose "Successfully removed DSC PHP helper file."
}

# Internal function to throw terminating error with specified errroCategory, errorId and errorMessage
function New-TerminatingError
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [String]$errorId,
        
        [Parameter(Mandatory)]
        [String]$errorMessage,

        [Parameter(Mandatory)]
        [System.Management.Automation.ErrorCategory]$errorCategory
    )
    
    $exception = New-Object System.InvalidOperationException $errorMessage 
    $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $errorId, $errorCategory, $null
    throw $errorRecord
}