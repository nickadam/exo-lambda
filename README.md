# exo-lambda
Exchange Online Management PowerShell tools on lambda

I have had a heck of a time getting Exchange Online Management to run in lambda.
The primary issue has to do with PSWSMan replacing shared object files when you
run Install-WSMan. This issue has taken me on quite the yack shaving adventure.

Here is what I learned:
- AWS does not provide a container image for PowerShell lambdas, [823](https://github.com/aws/aws-lambda-dotnet/issues/823)
- AWS lambda container images are based on Amazon Linux AMI 2018.03 [which hasn't been supported since 2020](https://aws.amazon.com/amazon-linux-ami/) (yet they are still patching lambdas)
- PowerShell cannot be easily installed on Amazon Linux AMI 2018.03 (requires openssl-libs)
- PowerShell can be easily installed on Amazon Linux 2 (openssl-libs is available)
- There is "stuff" in lambda container images that implements the [lambda runtime API](https://docs.aws.amazon.com/lambda/latest/dg/runtimes-api.html)

And here is the resultant idea:
- Start with microsoft powershell
- Install ExchangeOnlineMangement
- Install python
- Implement the AWS lambda "stuff" with python
- Establish a method of executing ps1 scripts

## Environment variables
Name | Required | Acceptable values | Value if not specified | Description
---|---|---|---|---
PWSH_SCRIPT | No | | /script/example_script.ps1 | Path to script that will be executed, see `example_script.ps1`
FAIL_IF_STDERR | No | 1, 0 | 0 | Cause the lambda function to fail if there is any output in STDERR
OUTPUT | No | STDOUT, STDERR, LAST_LINE_JSON | STDOUT and STDERR | Specify if you want just stdout, just stderr, or to parse the last line of your script output as a JSON object
AAD_APPID | Yes | | | The app id from Azure AD app registration
AAD_ORGANIZATION | Yes | | | Your organization, example.onmicrosoft.com
PFX_PASSWORD | Yes | | | The password to you pfx
PFX_PATH | No | | | Path to the pfx if you want to include it in the image (not recommended for prod but good for testing)
PFX_AWS_SECRET_NAME | No | | | The name of you AWS secret that contains the binary pfx (use in prod)


## Testing with [RIE](https://docs.aws.amazon.com/lambda/latest/dg/images-test.html)
```
git clone https://github.com/nickadam/exo-lambda.git
cd exo-lambda

docker compose build -t exo-lambda-test

docker run --rm \
  -e AWS_LAMBDA_RUNTIME_API=/aws-lambda/aws-lambda-rie \
  -e PFX_PATH=/exchange.pfx \
  -e PFX_PASSWORD=password \
  -e AAD_APPID=7b8ecf48-910d-4ddc-baff-995508d60cd6 \
  -e AAD_ORGANIZATION=myorg.onmicrosoft.com \
  -v ~/exchange.pfx:/exchange.pfx \
  -v ~/.aws-lambda-rie:/aws-lambda \
  -p 9000:8080 \
  --entrypoint /aws-lambda/aws-lambda-rie \
  python3 -m awslambdaric execpwsh.handler

curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" -d '{"arg": "some argument"}'
```
