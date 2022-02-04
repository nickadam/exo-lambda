import subprocess
import json
import os
import base64

def convertto_base64(input_object):
    return str(base64.b64encode(json.dumps(input_object).encode('utf-8')), 'utf-8')

def handler(event, context):
    script = os.getenv('PWSH_SCRIPT')
    check_stderr = os.getenv('FAIL_IF_STDERR') == '1'
    out_stdout = os.getenv('OUTPUT') == 'STDOUT'
    out_stderr = os.getenv('OUTPUT') == 'STDERR'
    out_json = os.getenv('OUTPUT') == 'LAST_LINE_JSON'

    context_props = {
        'function_name': context.function_name,
        'function_version': context.function_version,
        'invoked_function_arn': context.invoked_function_arn,
        'memory_limit_in_mb': context.memory_limit_in_mb,
        'aws_request_id': context.aws_request_id,
        'log_group_name': context.log_group_name,
    }

    encoded_event_and_context = convertto_base64({
        'event': event,
        'context': context_props,
    })

    cmd = ['pwsh', '-Command', f'& \u007b{script} {encoded_event_and_context}\u007d']
    o = subprocess.run(cmd, encoding='utf-8', stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = o.stdout.strip()
    stderr = o.stderr.strip()

    if check_stderr and stderr:
        raise Exception(stderr)

    if out_stdout:
        return stdout

    if out_stderr:
        return stderr

    if out_json:
        return json.loads(stdout.split('\n')[-1])

    return {
        'stdout': stdout,
        'stderr': stderr
    }
