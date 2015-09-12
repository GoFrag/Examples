<#
 EXTERNALHELP <Help.xml>
#> 

##
## Test script
##

function Write-ToPipe
{
    param ($Data)

    Write-Verbose ("Writing data to pipe: $Data")
    Write-Output $Data
}

function Split-String
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true, ValueFromPipeline)]
        [string] $String
    )

    return $String -split " "
}

function Count-Words
{
    param (
        [string] $FilePath
    )

    $segments = Get-Content -Path $FilePath -Raw | Split-String | sort

    $hash = @{}
    foreach ($segment in $segments)
    {
        if (![string]::IsNullOrEmpty($segment))
        {
            if ($hash.ContainsKey($segment))
            {
                $hash[$segment]++
            }
            else
            {
                $hash += @{$segment = 1}
            }
        }
    }

    Write-ToPipe $hash.Count
    foreach ($item in ($hash.GetEnumerator() | sort -Property Name))
    {
        Write-ToPipe $item
    }
}

Count-Words -FilePath C:\Scripts\temp.txt
