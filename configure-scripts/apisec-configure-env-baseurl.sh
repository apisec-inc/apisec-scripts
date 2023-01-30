#!/bin/bash
# Begin
#
#
#
# Script Purpose: This script will create an environment as well as update baseUrl of an existing environment of a existing project on APIsec platform.
#                 Flow of the script is as such it will create an environment if one doesn't exist for a name passed with parameter(--envName).
#                 But however if an environment with passed parameter(--envName) already exist then script will update baseUrl with the string passed with the parameter --baseUrl.
# 
#
# How to run the this script.
# Syntax:        bash apisec-configure-env-baseurl.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --envName <name-of-environment-to-create-or-update>   --baseUrl  "<baseUrl-of-the-openApiSpec>"

# Example usage: bash apisec-configure-env-baseurl.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --envName "UAT"                                       --baseUrl   "http://netbanking.apisec.ai:8080"      


TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,envName:,baseUrl:" -- -- "$@")

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
                    --baseUrl) BASE_URL="$2"; shift;;                    
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
echo " "

dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
PROJECT_ID=$(echo "$dto" | jq -r '.id')
data=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')

env_names=$(jq -r '.name' <<< "$data")
env_names_count=( $env_names )
env_names_count=$(echo ${#env_names_count[*]})

lCount=0
for env in ${env_names}
    do
         if [ "$ENV_NAME" != "$env" ]; then
               lCount=`expr $lCount + 1` 
         fi      
    done
if [ $lCount -eq $env_names_count ]; then      
      echo "Creating $ENV_NAME environment with $BASE_URL as baseurl in $FX_PROJECT_NAME project!!"
      Data=$(curl -s --location --request POST "${FX_HOST}/api/v1/envs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"auths":[],"name":"'${ENV_NAME}'","baseUrl":"'${BASE_URL}'","projectId":"'${PROJECT_ID}'"}' | jq -r '.data')
      createdBaseUrl=$(echo "$Data" | jq -r '.baseUrl')
      createdEnvID=$(echo "$Data" | jq -r '.id')
      echo " "
      echo "ProjectName: $FX_PROJECT_NAME"
      echo "ProjectId: $PROJECT_ID"
      echo "EnvironmentName: $ENV_NAME"
      echo "EnvironmentId: $createdEnvID"
      echo "UpdatedBaseUrl: $createdBaseUrl"
      echo " "

else
     for row in $(echo "${data}" | jq -r '. | @base64'); 
         do
               _jq() {
                    echo ${row} | base64 --decode | jq -r ${1}
                }
                eName=$(echo $(_jq '.') | jq  -r '.name')
                eId=$(echo $(_jq '.') | jq  -r '.id') 
    
               if [ "$ENV_NAME" == "$eName"  ]; then
                     echo "Updating $ENV_NAME environment with $BASE_URL as baseurl in $FX_PROJECT_NAME project!!"
                     dto=$(echo $(_jq '.') | jq '.baseUrl = "'${BASE_URL}'"')
                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$dto" | jq -r '.data')
                     updatedBaseUrl=$(echo "$updatedData" | jq -r '.baseUrl')
                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "EnvironmentName: $ENV_NAME"
                     echo "EnvironmentId: $eId"
                     echo "UpdatedBaseUrl: $updatedBaseUrl"
                     echo " "                 
                     

               fi
        done
      
fi

echo "Script Execution is finished."