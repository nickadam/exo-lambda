$PFX_AWS_SECRET_NAME = $Env:PFX_AWS_SECRET_NAME
$PFX_PATH = $Env:PFX_PATH
$PFX_PASSWORD = $Env:PFX_PASSWORD
$AAD_APPID = $Env:AAD_APPID
$AAD_ORGANIZATION = $Env:AAD_ORGANIZATION

# Get pfx from AWS Secrets Manager
if($PFX_AWS_SECRET_NAME){
  $pfx = '/tmp/ExchangeOnline.pfx'
  $fso = New-Object -TypeName "System.IO.FileStream" -ArgumentList $pfx, Create
  (Get-SECSecretValue -SecretId ExchangeOnlineUserAdministrator).SecretBinary.WriteTo($fso)
  $fso.Flush()
  $fso.Dispose()
}

# Get pfx from local path
if($PFX_PATH){
  $pfx = $PFX_PATH
}

if($PFX_PASSWORD){
  $PfxPwSecureString = (ConvertTo-SecureString -String $PFX_PASSWORD -AsPlainText -Force)
}

Connect-ExchangeOnline -CertificateFilePath $pfx -CertificatePassword $PfxPwSecureString -AppID $AAD_APPID -Organization $AAD_ORGANIZATION 2>&1 | Out-File /dev/null
