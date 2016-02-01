#
# Configuration script defining partial config using logger resource 
#
# Copyright (c) Microsoft Corporation, 2014
#

configuration Logger2
{

    Import-dscresource -ModuleName PsModuleForTestLogger1_3

    Node "Logger2.1C707B86-EF8E-4C29-B7C1-34DA2190AE24"
    {
     
	    TestLogger2 Test3
        {
                Id =  "Logger2"
                TestLogMessage = "Test Message From Logger2"
                LogTime =  ([dateTime]::Now).ToString()
        }
    }
}

Logger2 -output "$env:temp\PartialConfigTest2"