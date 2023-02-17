#!/bin/bash
# Begin
# Script Purpose: This script will register a project on APIsec platform using URL of the openapisec.
# 
#
# How to run the this script.
# Syntax:        bash apisec-project-creation-script.sh  --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>"    --openApiSpecUrl  "<URL-of-the-openApiSpec>"

# Example usage: bash apisec-project-creation-script.sh  --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"       --openAPISpecFile   "http://netbanking.apisec.ai:8080/v2/api-docs"




TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,openApiSpecUrl:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --openApiSpecUrl) FX_OpenAPISpecUrl="$2"; shift;;
                    --tags) FX_TAGS="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done
    


if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

 

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

echo "generated token is:" $token
echo ' '

#data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECT_NAME}'","openAPISpec":"none","planType":"ENTERPRISE","isFileLoad": "true","openText": '${openText}',"source": "API","personalizedCoverage":{"auths":[]}}'  | jq -r '.data') 
data=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECT_NAME}'","openAPISpec":"'${FX_OpenAPISpecUrl}'","planType":"ENTERPRISE","isFileLoad": false,"personalizedCoverage":{"auths":[]}}' | jq -r '.data')
echo ' '
project_name=$(jq -r '.name' <<< "$data")
project_id=$(jq -r '.id' <<< "$data")

if [ -z "$project_id" ] || [  "$project_id" == null ]; then
      echo "Project Id is $project_id/empty" > /dev/null
else
      
     echo "Successfully created the project."
     echo "ProjectName: $project_name"
     echo "ProjectId: $project_id"
     echo 'Script Execution is Done.'
fi
