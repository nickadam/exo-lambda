package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"bytes"
	"os"
	"os/exec"
	"strings"
)

type Event struct {
	Arg string `json:"arg"`
}

type Response struct {
	StdOut string `json:"stdout"`
	StdErr string `json:"stderr"`
}

func HandleLambdaEvent(event Event) (Response, error) {
	script := os.Getenv("PWSH_SCRIPT")

	var cmd *exec.Cmd

	if event.Arg != "" {
		cmd = exec.Command("pwsh", "-File", script, event.Arg)
	}else{
		cmd = exec.Command("pwsh", "-File", script)
	}

	var stdout, stderr bytes.Buffer
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	err := cmd.Run()

	response := Response{
		StdOut: strings.TrimSpace(stdout.String()),
		StdErr: strings.TrimSpace(stderr.String()),
	}

	if os.Getenv("IGNORE_ERROR") == "1" {
		return response, nil
	}else{
		return response, err
	}

}

func main() {
	lambda.Start(HandleLambdaEvent)
}
