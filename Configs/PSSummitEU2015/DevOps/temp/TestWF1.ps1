##
##
##

workflow TestFn1
{
    param (
        $Count = 100
    )

    "Running Workflow"

    for ($i=1; $i -le $Count; $i++)
    {
        "Write Loop Count: $i"
        Start-Sleep -Seconds 1
    }

    "Workflow Complete"
}

TestFn1 -asjob
