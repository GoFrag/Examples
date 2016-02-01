#
# Configuration script defining partial config using logger resource 
#
# Copyright (c) Microsoft Corporation, 2014
#

configuration Logger6
{

    Import-dscresource -ModuleName PsModuleForTestLogger6_10

    Node "Logger6.1C707B86-EF8E-4C29-B7C1-34DA2190AE24"
    {
     
	    TestLogger6 Test2
        {
                Id =  "Logger6"
                TestLogMessage = "Test Message From Logger6"
                LogTime =  ([dateTime]::Now).ToString()
        }
    }
}

Logger6 -output "$env:temp\PartialConfigTest1"