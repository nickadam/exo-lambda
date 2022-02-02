FROM golang:1.17 as build

RUN mkdir /root/execpwsh

WORKDIR /root/execpwsh

COPY go.mod go.sum ./
RUN go mod download

# Build execpwsh
COPY execpwsh.go ./
RUN go build -o /execpwsh


FROM public.ecr.aws/lambda/provided:al2

# install powershell
RUN yum install -y https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm

COPY --from=build /execpwsh /

COPY example_script.ps1 /script/

ENV PWSH_SCRIPT=/script/example_script.ps1
ENV IGNORE_ERROR=1

ENTRYPOINT ["/execpwsh"]
