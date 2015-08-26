

#region Generate certificate to be used to encrypt passwords in Pull Server config
$Certificate = ls Cert:\LocalMachine\My | ? {$_.Subject -eq "CN=$env:COMPUTERNAME" -and $_.PrivateKey.KeyExchangeAlgorithm} | Select -First 1 
if(!$Certificate)
{
    $Certificate = New-SelfSignedCertificate -Provider 'Microsoft RSA SChannel Cryptographic Provider' -DnsName $env:COMPUTERNAME -CertStoreLocation 'Cert:\LocalMachine\My'
}

$CertificateFile = Test-Path 'c:\configs\cert.cer'
if(!$CertificateFile)
{
    $CertificateFile = Export-Certificate -Type CERT -FilePath 'c:\configs\cert.cer' -Cert $Certificate
}

$ImportedToTrustedRoot = ls Cert:\LocalMachine\Root | ? {$_.Thumbprint -eq $Certificate.Thumbprint}
if(!$ImportedToTrustedRoot)
{
    Import-Certificate -FilePath $CertificateFile -CertStoreLocation 'Cert:\LocalMachine\Root'
}

#endregion Generate certificate to be used to encrypt passwords in Pull Server config

[DscLocalConfigurationManager()]
Configuration Meta
{
    Settings
    {
        CertificateID = $Certificate.Thumbprint
    }

}

Meta -OutputPath c:\configs\MOF\

#Set-DscLocalConfigurationManager -Path c:\Configs\MOF\ -Verbose