#!/bin/bash
# Begin
#
#
#
# Script Purpose: This script will update creds of existing an environment.
#                 
# 
#
# How to run the this script.
# Syntax:        bash apisec-configure-creds.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --envName <existing-environmentName>   --creds  "<path-to-creds-file>"

# Example usage: bash apisec-configure-creds.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --envName "UAT"                        --creds  "netbank-basic-auth-creds.json"      


TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,envName:,creds:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		            --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --envName) ENV_NAME="$2"; shift;;                    
                    --creds) CREDS="$2"; shift;;                    
                    --) shift;;
             esac
             shift;
    done
    
if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi
auth=$(cat $CREDS)
token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

echo "generated token is:" $token
echo " "

dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
PROJECT_ID=$(echo "$dto" | jq -r '.id')
data=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')

     for row in $(echo "${data}" | jq -r '. | @base64'); 
         do
               _jq() {
                    echo ${row} | base64 --decode | jq -r ${1}
                }
                eName=$(echo $(_jq '.') | jq  -r '.name')
                eId=$(echo $(_jq '.') | jq  -r '.id') 
    
               if [ "$ENV_NAME" == "$eName"  ]; then
                     echo "Updating $ENV_NAME environment with $BASE_URL as baseurl in $FX_PROJECT_NAME project!!"
                     dto=$(echo $(_jq '.') | jq '.auths = '${auth}'')
                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" | jq -r '.data')
                     updatedAuths=$(echo "$updatedData" | jq -r '.auths')                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "EnvironmentName: $ENV_NAME"
                     echo "EnvironmentId: $eId"
                     echo "UpdatedAuths: $updatedAuths"
                     echo " "                 
                     

               fi
        done

echo "Script Execution is finished."

# env_names=$(jq -r '.name' <<< "$data")
# env_names_count=( $env_names )
# env_names_count=$(echo ${#env_names_count[*]})

# lCount=0
# for env in ${env_names}
#     do
#          if [ "$ENV_NAME" != "$env" ]; then
#                lCount=`expr $lCount + 1` 
#          fi      
#     done
# if [ $lCount -eq $env_names_count ]; then      
#       echo "Creating $ENV_NAME environment with $BASE_URL as baseurl in $FX_PROJECT_NAME project!!"
#       Data=$(curl -s --location --request POST "${FX_HOST}/api/v1/envs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"auths":'${auth}',"name":"'${ENV_NAME}'","baseUrl":"'${BASE_URL}'","projectId":"'${PROJECT_ID}'"}' | jq -r '.data')
#       createdBaseUrl=$(echo "$Data" | jq -r '.baseUrl')
#       createdEnvID=$(echo "$Data" | jq -r '.id')
#       echo " "
#       echo "ProjectName: $FX_PROJECT_NAME"
#       echo "ProjectId: $PROJECT_ID"
#       echo "EnvironmentName: $ENV_NAME"
#       echo "EnvironmentId: $createdEnvID"
#       echo "UpdatedBaseUrl: $createdBaseUrl"
#       echo " "

# else
#      for row in $(echo "${data}" | jq -r '. | @base64'); 
#          do
#                _jq() {
#                     echo ${row} | base64 --decode | jq -r ${1}
#                 }
#                 eName=$(echo $(_jq '.') | jq  -r '.name')
#                 eId=$(echo $(_jq '.') | jq  -r '.id') 
    
#                if [ "$ENV_NAME" == "$eName"  ]; then
#                      echo "Updating $ENV_NAME environment with $BASE_URL as baseurl in $FX_PROJECT_NAME project!!"
#                      dto=$(echo $(_jq '.') | jq '.auths = '${auth}'')
#                      updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" | jq -r '.data')
#                      updatedAuths=$(echo "$updatedData" | jq -r '.auths')                     
#                      echo " "
#                      echo "ProjectName: $FX_PROJECT_NAME"
#                      echo "ProjectId: $PROJECT_ID"
#                      echo "EnvironmentName: $ENV_NAME"
#                      echo "EnvironmentId: $eId"
#                      echo "UpdatedAuths: $updatedAuths"
#                      echo " "                 
                     

#                fi
#         done
      
# fi

# echo "Script Execution is finished."