FROM mcr.microsoft.com/powershell:latest AS pip

RUN apt-get update && apt-get install -y python3-pip

RUN mkdir /function && \
  pip install --target /function awslambdaric

FROM mcr.microsoft.com/powershell:latest

# TODO cleanup cache
RUN apt-get update && apt-get install -y python3

# Install powershell modules
RUN pwsh -command 'Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Force \
  && Install-Module -Name PSWSMan -Scope AllUsers -Force \
  && Install-Module -Name AWS.Tools.Installer -Scope AllUsers -Force \
  && Install-AWSToolsModule AWS.Tools.SecretsManager,AWS.Tools.S3 -Scope AllUsers -Force \
  && Install-WSMan'

COPY --from=pip /function /function

COPY example_script.ps1 /script/
COPY execpwsh.py /function/

WORKDIR /function

ENV PWSH_SCRIPT=/script/example_script.ps1
ENV IGNORE_ERROR=1

ENTRYPOINT [ "/usr/bin/python3", "-m", "awslambdaric" ]

CMD [ "execpwsh.handler" ]
