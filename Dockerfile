FROM ubuntu:18.04

RUN apt update && apt install -y curl jq

ADD apisec_job_invoke_script.sh /apisec_job_invoke_script.sh

RUN chmod a+x /apisec_job_invoke_script.sh

ENTRYPOINT ["/bin/bash", "-c", "/apisec_job_invoke_script.sh --host $hostUrl --username $username  --password $password --project $projectName --profile $profile --scanner $scanner --emailReport $email --reportType $report --fail-on-high-vulns $fail-on-high-vulns" ]
