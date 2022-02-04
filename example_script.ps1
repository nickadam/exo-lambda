$AWS = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($args)) | ConvertFrom-Json

# $AWS.context.function_name
# $AWS.context.function_version
# $AWS.context.invoked_function_arn
# $AWS.context.memory_limit_in_mb
# $AWS.context.aws_request_id
# $AWS.context.log_group_name
# $AWS.event

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
$PfxPwSecureString = (ConvertTo-SecureString -String $PFX_PASSWORD -AsPlainText -Force)

function Connect-EXO {
  Connect-ExchangeOnline -CertificateFilePath $pfx -CertificatePassword $PfxPwSecureString -AppID $AAD_APPID -Organization $AAD_ORGANIZATION
}


# your code below

if($AWS.Event.EmailAddress){
  Connect-EXO # this takes a long time (~1 min)
  Get-EXOMailbox $AWS.Event.EmailAddress | ConvertTo-Json -Compress
}
