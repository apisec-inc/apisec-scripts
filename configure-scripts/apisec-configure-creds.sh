#!/bin/bash
# Begin
#
#
#
# Script Purpose: This script will update creds of authName in existing an environment.
#                 
# 
#
# How to run the this script.
#
# Use-Case 1: To Update credentials of Basic AuthType
# Syntax:        bash apisec-configure-creds.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --envName <existing-environmentName>   --authName <auth Name>   --app_username <app userName>          --app_password <app password> 
#
# Example usage: bash apisec-configure-creds.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --envName "Master"                     --authName "Default"     --app_username "user1@netbanking.io"   --app_password "admin@1234"

# Use-Case 2: To Update credentials of Token AuthType
# Syntax:        bash apisec-configure-creds.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --envName <existing-environmentName>   --authName <auth Name>   --app_username <app userName>          --app_password  <app password>  --app_endPointUrl <app's complete token endpoint url>         --app_token_param <token param to filter generated token>
#
# Example usage: bash apisec-configure-creds.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --envName "Master"                     --authName "ROLE_PM"     --app_username "user1@netbanking.io"   --app_password  "admin@1234"    --app_endPointUrl "https://netbanking.apisec.ai:8080/login"   --app_token_param ".info.token"





TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,envName:,authName:,app_username:,app_password:,app_endPointUrl:,app_token_param:" -- -- "$@")

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
                    --authName) AUTH_NAME="$2"; shift;;
                    --app_endPointUrl) ENDPOINT_URL="$2"; shift;;       
                    --app_username) APP_USER="$2"; shift;;
                    --app_password) APP_PWD="$2"; shift;; 
                    --app_token_param) TOKEN_PARAM="$2"; shift;;           
                    --) shift;;
             esac
             shift;
    done
    
if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

if [ "$TOKEN_PARAM" = "" ];
then
    TOKEN_PARAM=".info.token"
fi

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
                     updatedAuths=$(echo $(_jq '.') | jq -r '.auths[]')
                     updatedAuths1=$(echo $(_jq '.') | jq -r '.auths')
                     for row1 in $(echo "${updatedAuths}" | jq -r '. | @base64');
                         do
                                _pq() {
                                     echo ${row1} | base64 --decode | jq -r ${1}
                                }
                                authType=$(echo $(_pq '.') | jq -r '.authType')                                
                                authName=$(echo $(_pq '.') | jq -r '.name')

                                case "$authType" in "Basic")   if [ "$authName" == "$AUTH_NAME" ]; then   
                                                                     echo "Updating '$AUTH_NAME' Auth with Basic as AuthType of '$ENV_NAME' environment in '$FX_PROJECT_NAME' project!!"
                                                                     echo " "
                                                                     bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.username = "'${APP_USER}'" | .password = "'${APP_PWD}'"))' | jq -c .) 
                                                                     udto=$(echo $(_jq '.') | jq '.auths = '"${bAuth}"'')
                                                                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 
                                                                     updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                          for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                             do
                                                                                    _aq() {
                                                                                             echo ${row2} | base64 --decode | jq -r ${1}
                                                                                          }
                                                                                          upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                          if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                          fi
                                                                             done              
                                                                     echo " " 
                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                     echo "EnvironmentId: $eId" 
                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                     echo " " 
                                                               fi ;;
                                                     
                                                     "Digest")   if [ "$authName" == "$AUTH_NAME" ]; then   
                                                                     echo "Updating '$AUTH_NAME' Auth with Digest as AuthType of '$ENV_NAME' environment  in '$FX_PROJECT_NAME' project!!"
                                                                     echo " "
                                                                     bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.username = "'${APP_USER}'" | .password = "'${APP_PWD}'"))' | jq -c .) 
                                                                     udto=$(echo $(_jq '.') | jq '.auths = '"${bAuth}"'')
                                                                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 
                                                                     updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                          for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                             do
                                                                                    _aq() {
                                                                                             echo ${row2} | base64 --decode | jq -r ${1}
                                                                                          }
                                                                                          upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                          if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                          fi
                                                                             done              
                                                                     echo " " 
                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                     echo "EnvironmentId: $eId" 
                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                     echo " " 
                                                               fi ;;

                                                    "Token")   if [ "$authName" == "$AUTH_NAME" ]; then 
                                                                     echo "Updating '$AUTH_NAME' Auth with Token as AuthType of '$ENV_NAME' environment in '$FX_PROJECT_NAME' project!!"
                                                                     echo " "  
                                                                     auth='Authorization: Bearer {{@CmdCache | curl -s -d '\'{\""username"\":\""${APP_USER}"\",\""password"\":\""${APP_PWD}"\"}\'' -H '\""Content-Type: application/json"\"' -H '\""Accept: application/json"\"' -X POST '${ENDPOINT_URL}' | jq --raw-output '"\"${TOKEN_PARAM}"\"' }}'
                                                                     echo $auth
                                                                     echo " "
                                                                     #bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = "'"${auth}"'" ))' | jq -c . )
                                                                     bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = "Authorization: Bearer {{@CmdCache | curl -s -d '{"username":"syedimran@apisec.ai","password":"Dev@ops5665"}' -H "Content-Type: application/json" -H "Accept: application/json" -X POST https://apitest.apisec.ai/login | jq --raw-output ".token" }}" ))' | jq -c . )
                                                                     exit 1
                                                                     #bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = '"${auth}"' ))' | jq -c . )
                                                                     udto=$(echo $(_jq '.') | jq '.auths = '"${bAuth}"'')
                                                                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 
                                                                     updatedAuths=$(echo "$updatedData" | jq -r '.auths[]')
                                                                          for row3 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                             do
                                                                                    _aq() {
                                                                                             echo ${row3} | base64 --decode | jq -r ${1}
                                                                                          }
                                                                                          upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                          if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                          fi
                                                                             done                                                                     
                                                                     echo " " 
                                                                     echo "ProjectName: $FX_PROJECT_NAME" 
                                                                     echo "ProjectId: $PROJECT_ID" 
                                                                     echo "EnvironmentName: $ENV_NAME" 
                                                                     echo "EnvironmentId: $eId" 
                                                                     echo "UpdatedAuth: $updatedAuthObj"
                                                                     echo " " 
                                                               fi ;;                                                                   
                                esac
                         done                   
               fi
        done

echo "Script Execution is finished."
