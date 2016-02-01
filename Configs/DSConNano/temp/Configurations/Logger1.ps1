#
# Configuration script defining partial config using logger resource 
#
# Copyright (c) Microsoft Corporation, 2014
#

configuration Logger1
{

    Import-dscresource -ModuleName PsModuleForTestLogger1_3

    Node "Logger1.1C707B86-EF8E-4C29-B7C1-34DA2190AE24"
    {
     
	    TestLogger1 Test1
        {
                Id =  "Logger1"
                TestLogMessage = "Test Message From Logger1"
                LogTime =  ([dateTime]::Now).ToString()
        }
    }
}

Logger1 -output "$env:temp\PartialConfigTest1"