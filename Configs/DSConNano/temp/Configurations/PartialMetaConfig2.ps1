#
# Meta Config defining partial configs  
#
# Copyright (c) Microsoft Corporation, 2014
#

param (
	    [String[]]$MachineName,
	    [String[]]$PullServers	
    )


[DscLocalConfigurationManager()]
configuration PartialConfigTest2
{

    Node $MachineName
    {
     
	    Settings
        {           
            ConfigurationID = "1C707B86-EF8E-4C29-B7C1-34DA2190AE24"
            RefreshMode = "PULL"
            RebootNodeIfNeeded = $true
        }
       
    	PartialConfiguration Logger2
        {
            Description = "Logger2"
            ConfigurationSource = @("[ConfigurationRepositoryWeb]PullServerWeb1")
        }

	    PartialConfiguration Logger3
        {
            Description = "Logger3"
            ConfigurationSource = @("[ConfigurationRepositoryWeb]PullServerWeb2")
	    }

	    ConfigurationRepositoryWeb PullServerWeb1
        {
            ServerURL = "http://" + $PullServers[0] + ":8080/PSDSCPullServer/PSDSCPullServer.svc"
	        AllowUnsecureConnection = $true
        }	

	    ConfigurationRepositoryWeb PullServerWeb2
        {
            ServerURL = "http://" + $PullServers[1] + ":8080/PSDSCPullServer/PSDSCPullServer.svc"
	        AllowUnsecureConnection = $true
        }	
    }

}

PartialConfigTest2 -output "$env:temp\PartialConfigTest2"