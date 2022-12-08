#!/bin/bash
# Begin

# Script Purpose: This script will register a project on APIsec platform using openapisec file upload method.
#
#
# How to run the this script.
# Syntax:        bash apisec-project-update-fileupload.sh  --host "<Hostname or IP>"         --username "<username>"       --password "<password>"    --project "<projectname>"    --openAPISpecFile   "<path-to-the-openApiSpec-json-file>"

# Example usage: bash apisec-project-update-fileupload.sh  --host "https://cloud.apisec.ai"  --username "admin@apisec.ai"  --password "apisec@5421"   --project "netbanking"       --openAPISpecFile   "./netbanking.json"      

# Note!!! Script requires yq tool to be installed for working with yaml files.

TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,openAPISpecFile:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --openAPISpecFile) openText="$2"; shift;;                 
                    --tags) FX_TAGS="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done
    

    


if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

fileExt=$(echo $openText)

if [[ "$fileExt" == *"yaml"* ]] ||  [[ "$fileExt" == *"yml"* ]]; then
     echo "yaml file upload option is used."
     openText=$(yq -r -o=json $openText)
     openText=${openText//\"/\\\"}
     openText=$(echo \"$openText\" | tr -d ' ')
fi

if [[ "$fileExt" == *"json"* ]]; then
      echo "json file upload option is used."
      openText=$(cat "$openText" )
      openText=${openText//\"/\\\"}
      openText=$(echo \"$openText\" | tr -d ' ')
fi 

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

echo "generated token is:" $token
echo ' '


dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
projectId=$(echo "$dto" | jq -r '.id')
orgId=$(echo "$dto" | jq -r '.org.id')

# curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request PUT "${FX_HOST}/api/v1/projects/${projectId}/" --header "Authorization: Bearer "$token"" -d  '{"id":"'${projectId}'","org":{"id":"'${orgId}'"},"name":"'${FX_PROJECT_NAME}'","openAPISpec":"None","openText": '${openText}',"isFileLoad":true}'

 curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request PUT "${FX_HOST}/api/v1/projects/${projectId}/refresh-specs" --header "Authorization: Bearer "$token"" -d  '{"id":"'${projectId}'","org":{"id":"'${orgId}'"},"name":"'${FX_PROJECT_NAME}'","openAPISpec":"None","openText": '${openText}',"isFileLoad":true}' >  /dev/null



    playbookTaskStatus="In_progress"
    echo "playbookTaskStatus = " $playbookTaskStatus
    retryCount=0
    pCount=0

    while [ "$playbookTaskStatus" == "In_progress" ]
           do
                if [ $pCount -eq 0 ]; then
                     echo "Checking playbooks regenerate task Status...."
                fi
                pCount=`expr $pCount + 1`  
                retryCount=`expr $retryCount + 1`  
                sleep 2

                playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${projectId}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '."data".status')
                #playbookTaskStatus="In_progress"
                if [ "$playbookTaskStatus" == "Done" ]; then
                     echo "OpenAPISpecFile upload and playbooks refresh task is succesfully completed!!!"
                fi

                if [ $retryCount -ge 55  ]; then
                     echo " "
                     retryCount=`expr $retryCount \* 2`  
                     echo "Playbook Regenerate Task Status $playbookTaskStatus even after $retryCount seconds, so halting script execution!!!"
                     exit 1
                fi                            
           done


echo ' '
echo 'Script Execution is Done.'
