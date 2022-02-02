FROM golang:1.17 as build

RUN mkdir /root/execpwsh

WORKDIR /root/execpwsh

COPY go.mod go.sum ./
RUN go mod download

# Build execpwsh
COPY execpwsh.go ./
RUN go build -o /execpwsh


FROM mcr.microsoft.com/powershell:latest

# Install powershell modules
RUN pwsh -command 'Install-Module -Name ExchangeOnlineManagement -Scope AllUsers -Force \
  && Install-Module -Name PSWSMan -Scope AllUsers -Force \
  && Install-Module -Name AWS.Tools.Installer -Scope AllUsers -Force \
  && Install-AWSToolsModule AWS.Tools.SecretsManager,AWS.Tools.S3 -Scope AllUsers -Force \
  && Install-WSMan'

COPY --from=build /execpwsh /

COPY example_script.ps1 /script/

ENV PWSH_SCRIPT=/script/example_script.ps1
ENV IGNORE_ERROR=1

ENTRYPOINT ["/execpwsh"]
