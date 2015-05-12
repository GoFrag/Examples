.\makecert -n "CN=DSC Demo Root Authority" -cy authority -a sha1 -sv "DSC Demo Root Authority.pvk" -r "DSC Demo Root Authority.cer" -pe
.\pvk2pfx -pvk "DSC Demo Root Authority.pvk" -spc "DSC Demo Root Authority.cer" -pfx "DSC Demo Root Authority.pfx"

.\makecert -n "CN=DSCDemo" -sky exchange -ic "DSC Demo Root Authority.cer" -iv "DSC Demo Root Authority.pvk" -a sha1 -pe -sv DSCDemo.pvk DSCDemo.cer
.\pvk2pfx -pvk DSCDemo.pvk -spc DSCDemo.cer -pfx DSCDemo.pfx 

.\makecert -n "CN=DSCServer.contoso.com" -sky exhange -ic "DSC Demo Root Authority.cer" -iv "DSC Demo Root Authority.pvk" -a sha1 -pe -sv PullServer.pvk PullServer.cer
.\pvk2pfx -pvk PullServer.pvk -spc PullServer.cer -pfx PullServer.pfx 
