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
- Start with Amazon Linux 2
- Add the "stuff" from another lambda container image to implement the runtime API
- Install PowerShell
- Install ExchangeOnlineMangement
- Establish a method of executing ps1 scripts

For the "stuff", I figured the [lambda container image for go](https://github.com/aws/aws-lambda-base-images/tree/go1.x) may have the least amount of junk
since go programs are compiled and statically linked.
