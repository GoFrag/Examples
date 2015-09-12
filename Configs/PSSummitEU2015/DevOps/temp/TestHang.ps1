##
## Test Script Hang
##

$typeDefinition = @'
    using System;

    public class InvokeHang
    {
        public bool isHang;

        public InvokeHang()
        {
            isHang = true;
        }

        public void DoHang()
        {
            while (isHang)
            {
                System.Threading.Thread.Sleep(1000);
            }
        }
    }
'@

Add-Type -TypeDefinition $typeDefinition
$InvokeHang = New-Object InvokeHang

function Invoke-SpecialProcessing
{
    param (
        $item
    )

    ""
    "Starting special processing for item: $Item"
    "This may hang"
    $InvokeHang.DoHang()
    "Special processing complete"
}

function Invoke-OverCollection
{
    param (
        [object[]] $Items,

        [int] $RandomItemHang = 35
    )

    $count = 1
    foreach ($item in $Items)
    {
        "Start Processing of Item: $item.ToString()"

        if ($count++ -eq $RandomItemHang)
        {
            Invoke-SpecialProcessing $item
        }

        Write-Output $item

        "Finished Processing"
    }
}

$items = @()

Get-Service | foreach {
    $items += $_
}

Get-Process | foreach {
    $items += $_
}

Invoke-OverCollection $items
