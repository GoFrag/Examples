Configuration DevFileServer
{
    Import-DscResource -Name xSmbShare -ModuleName xSmbShare
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    #User Home directories
    file Users
    {
            Ensure           = 'Present'
            Type             = 'Directory'
            DestinationPath  = 'c:\Shares\Users'
        }

    xSmbShare UsersShare
    {
            Ensure                  = 'Present'
            Name                    = 'Dev_Users'
            Path                    = 'c:\Shares\Users'
            FullAccess              = 'Administrators'
            ReadAccess              = 'Everyone'
            FolderEnumerationMode   = 'AccessBased'
            DependsOn               = '[File]Users'
        }

    #Source directories
    file Source
    {
            Ensure                  = 'Present'
            DestinationPath         = 'c:\Shares\Source'
            SourcePath              = '\\MCG-Lenovo\DevShares\Source'
            Recurse                 = $true
            MatchSource             = $true
        }

    xSmbShare SourceCodeShare
    {
            Ensure                  = 'Present'
            Name                    = 'Dev_Source'
            Path                    = 'c:\Shares\Source'
            FullAccess              = 'Administrators'
            ReadAccess              = 'Everyone'
            FolderEnumerationMode   = 'AccessBased'
            DependsOn               = '[File]Source'
        }

    #Software directories
    file Software
    {
            Ensure                 = 'Present'
            DestinationPath        = 'c:\Shares\Software'
            SourcePath             = '\\MCG-Lenovo\DevShares\Software'
            Recurse                = $true
            MatchSource            = $true
        }

    xSmbShare SoftwareShare
    {
            Ensure                 = 'Present'
            Name                   = 'Dev_Software'
            Path                   = 'c:\Shares\Software'
            FullAccess             = 'Administrators'
            ReadAccess             = 'Everyone'
            FolderEnumerationMode  = 'AccessBased'
            DependsOn              = '[File]Software'
        }

    # Set registry and Env variables
    Registry Lanman # Specifies the size of request buffers that the server uses
    {
     	    Ensure    = 'Present'
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters'
            ValueType = 'Dword'
            ValueName = 'SizReqBuf'
            ValueData = 65535
        }

    Environment Path
    {
            Ensure  = "present"
            Name    = "ServerType"
            Value   = "FileServer"
        }
}

DevFileServer -OutputPath c:\Configs\Mof\ -verbose