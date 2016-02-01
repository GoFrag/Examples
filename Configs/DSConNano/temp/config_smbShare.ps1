configuration config
{
    Import-DscResource -Module xSmbShare

    xSmbShare share
    {
     	Ensure = "Present" 
        Name   = "Dsc4Nano"
        Path = "C:\nano";
        ReadAccess = "everyone"  
    }
}

config
