FROM golang:1.17 as build

COPY execpwsh.go /root/execpwsh/execpwsh.go

# build execpwsh
RUN cd /root/execpwsh && \
  go mod init execpwsh && \
  go mod tidy && \
  go build

FROM public.ecr.aws/lambda/go:1 AS old

FROM public.ecr.aws/amazonlinux/amazonlinux:2

COPY --from=old /lambda-entrypoint.sh /lambda-entrypoint.sh
COPY --from=old /var/runtime /var/runtime
COPY --from=old /usr/local/bin/aws-lambda-rie /usr/local/bin/aws-lambda-rie

# from https://github.com/aws/aws-lambda-base-images/blob/go1.x/Dockerfile.go1.x
ENV LANG=en_US.UTF-8
ENV TZ=:/etc/localtime
ENV PATH=/var/lang/bin:/usr/local/bin:/usr/bin/:/bin:/opt/bin
ENV LD_LIBRARY_PATH=/var/lang/lib:/lib64:/usr/lib64:/var/runtime:/var/runtime/lib:/var/task:/var/task/lib:/opt/lib
ENV LAMBDA_TASK_ROOT=/var/task
ENV LAMBDA_RUNTIME_DIR=/var/runtime

WORKDIR /var/task

ENTRYPOINT ["/lambda-entrypoint.sh"]

# install powershell
RUN yum install -y https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/powershell-lts-7.2.1-1.rh.x86_64.rpm

COPY --from=build /root/execpwsh/execpwsh ${LAMBDA_TASK_ROOT}

COPY example_script.ps1 /var/task/

ENV PWSH_SCRIPT=example_script.ps1
ENV IGNORE_ERROR=1

CMD ["execpwsh"]
