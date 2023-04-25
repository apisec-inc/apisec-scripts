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
# Syntax:        bash apisec-configure-creds.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --envName <existing-environmentName>   --authName <auth Name>   --header_1 <complete header 1 curl request to  generate token>
#
# Example usage: bash apisec-configure-creds.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --envName "Master"                     --authName "ROLE_PM"     --header_1 "Authorization: Bearer {{@CmdCache | curl -s -d '{"username":"admin","password":"secret"}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST https://ip/user/login | jq --raw-output '.info.token' }}"





TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,envName:,authName:,app_username:,app_password:,app_endPointUrl:,app_token_param:,header_1:" -- -- "$@")

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
                    --header_1) COMPLETE_HEADER1="$2"; shift;;                              
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

tokenResp=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login )
#tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | cut -d{ -f1 | cut -d} -f2 | cut -d'"' -f2)
tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | tr -d '{' | tr -d '}' | tr -d '"') 
if [ $tokenResp1 == "token" ];then
      token=$(echo $tokenResp | jq -r '.token')
      echo "generated token is:" $token
      echo " "  
elif [ $tokenResp1 == "message" ];then  
       message=$(echo $tokenResp | jq -r '.message')
       echo " "
       echo "$message. Please provide correct User Credentials!!"
       echo " "
       exit 1
fi

dtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
errorsFlag=$(echo "$dtoData" | jq -r '.errors')      
if [ $errorsFlag = true ]; then           
      errMsg=$(echo "$dtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
      echo $errMsg
      exit 1
elif [ $errorsFlag = false ]; then            
       dto=$(echo "$dtoData" | jq -r '.data')
       PROJECT_ID=$(echo "$dto" | jq -r '.id')
       getProjectName=$(echo "$dtoData" | jq -r '.data.name')
       #echo $getProjectName
fi

# dto=$(curl -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
# PROJECT_ID=$(echo "$dto" | jq -r '.id')

data=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')

EnvNames=$(echo $data | jq -r '.name')
EnvCount=0
for eName in ${EnvNames}
    do 
       if [ "$eName" == "$ENV_NAME" ]; then   
             EnvCount=`expr $EnvCount + 1`  
       fi
    done  
if [ $EnvCount -le 0 ]; then
      echo "$ENV_NAME environment doesn't exists in $FX_PROJECT_NAME project!!"
      exit 1
fi
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

                     AuthNames=$(echo $(_jq '.') | jq -r '.auths[].name')                                                      
                     AuthCount=0
                     for aName in ${AuthNames}
                         do 
                             if [ "$aName" == "$AUTH_NAME" ]; then   
                                   AuthCount=`expr $AuthCount + 1`  
                             fi
                         done  
                     if [ $AuthCount -le 0 ]; then
                          echo "$AUTH_NAME auth doesn't exists in $ENV_NAME environment  for $FX_PROJECT_NAME project!!"
                          exit 1
                     fi
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
                                                                     #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 
                                                                     updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto")
                                                                     uErrorsFlag=$(echo $updatedResp | jq -r '.errors')

                                                                     if [ $uErrorsFlag = true ]; then     
                                                                           errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                           echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                           exit 1
                                                                     elif [ $uErrorsFlag = false ]; then
                                                                            updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                            updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                            for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                do
                                                                                     _aq() {
                                                                                             echo ${row2} | base64 --decode | jq -r ${1}
                                                                                     }
                                                                                     upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                     if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                            updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                            echo " " 
                                                                                            echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                            echo "ProjectId: $PROJECT_ID" 
                                                                                            echo "EnvironmentName: $ENV_NAME" 
                                                                                            echo "EnvironmentId: $eId" 
                                                                                            echo "UpdatedAuth: $updatedAuthObj"
                                                                                            echo " "
                                                                                      fi
                                                                                done
                                                                     fi 
                                                               fi ;;
                                                     
                                                     "Digest")   if [ "$authName" == "$AUTH_NAME" ]; then   
                                                                     echo "Updating '$AUTH_NAME' Auth with Digest as AuthType of '$ENV_NAME' environment  in '$FX_PROJECT_NAME' project!!"
                                                                     echo " "
                                                                     bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.username = "'${APP_USER}'" | .password = "'${APP_PWD}'"))' | jq -c .) 
                                                                     udto=$(echo $(_jq '.') | jq '.auths = '"${bAuth}"'')
                                                                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 

                                                                     updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto")
                                                                     uErrorsFlag=$(echo $updatedResp | jq -r '.errors')

                                                                     if [ $uErrorsFlag = true ]; then     
                                                                           errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                           echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                 
                                                                           exit 1
                                                                     elif [ $uErrorsFlag = false ]; then
                                                                            updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                            updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                            for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                do
                                                                                     _aq() {
                                                                                             echo ${row2} | base64 --decode | jq -r ${1}
                                                                                     }
                                                                                     upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                     if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                            updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                            echo " " 
                                                                                            echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                            echo "ProjectId: $PROJECT_ID" 
                                                                                            echo "EnvironmentName: $ENV_NAME" 
                                                                                            echo "EnvironmentId: $eId" 
                                                                                            echo "UpdatedAuth: $updatedAuthObj"
                                                                                            echo " "
                                                                                      fi
                                                                                done
                                                                     fi 
                                                               fi ;;

                                                    "Token")   if [ "$authName" == "$AUTH_NAME" ]; then 
                                                                     echo "Updating '$AUTH_NAME' Auth with Token as AuthType of '$ENV_NAME' environment in '$FX_PROJECT_NAME' project!!"
                                                                     echo " "                                                                       
                                                                     #auth='Authorization: Bearer {{@CmdCache | curl -s -d '\'{"\"""username"\""":"\"""${APP_USER}"\""","\"""password"\""":"\"""${APP_PWD}"\"""}\'' -H '\'"Content-Type: application/json"\'' -H '\'"Accept: application/json"\'' -X POST '${ENDPOINT_URL}' | jq --raw-output '"'${TOKEN_PARAM}'"' }}'                                                                     
                                                                     auth=$(echo $COMPLETE_HEADER1)
                                                                     bAuth=$(echo $updatedAuths1 | jq --arg path "$auth" 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = $path ))' | jq -c . )
                                                                     #bAuth=$(echo $updatedAuths1 | jq 'map(select(.name == "'${AUTH_NAME}'") |= (.header_1 = "'"${auth}"'" ))' | jq -c . )
                                                                     echo " "
                                                                     udto=$(echo $(_jq '.') | jq '.auths = '"${bAuth}"'')
                                                                     #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data') 
                                                                     updatedResp=$(curl -s --location --request PUT "${FX_HOST}/api/v1/projects/$PROJECT_ID/env/$eId" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto")
                                                                     uErrorsFlag=$(echo $updatedResp | jq -r '.errors')
                                                                     if [ $uErrorsFlag = true ]; then     
                                                                           errMsg=$(echo "$updatedResp" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                                                                           echo $errMsg                                                                                                                                                                                                                                                                                                                                                                                                                  
                                                                           exit 1
                                                                     elif [ $uErrorsFlag = false ]; then
                                                                             updatedData=$(echo "$updatedResp" | jq -r '.data') 
                                                                             updatedAuths=$(echo "$updatedData" | jq -r '.auths[]') 
                                                                             for row2 in $(echo "${updatedAuths}" | jq -r '. | @base64'); 
                                                                                   do
                                                                                        _aq() {
                                                                                                echo ${row2} | base64 --decode | jq -r ${1}
                                                                                        }
                                                                                        upAuthName=$(echo $(_aq '.') | jq -r '.name')
                                                                                        if [ "$upAuthName" == "$AUTH_NAME" ]; then                                                                                                
                                                                                                updatedAuthObj=$(echo $(_aq '.') | jq -r .)
                                                                                                echo " " 
                                                                                                echo "ProjectName: $FX_PROJECT_NAME" 
                                                                                                echo "ProjectId: $PROJECT_ID" 
                                                                                                echo "EnvironmentName: $ENV_NAME" 
                                                                                                echo "EnvironmentId: $eId" 
                                                                                                echo "UpdatedAuth: $updatedAuthObj"
                                                                                                echo " "
                                                                                        fi
                                                                                   done
                                                                     fi
                                                               fi ;;                                                                   
                                esac
                         done                   
               fi
        done

echo "Script Execution is finished."
