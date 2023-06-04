#!/bin/bash
# Begin

TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,delProject:,profile:,scanner:,outputfile:,emailReport:,reportType:,fail-on-vuln-severity:,refresh-playbooks:,openAPISpecUrl:,openAPISpecFile:,internal_OpenAPISpecUrl:,specType:,profileScanner:,envName:,authName:,app_username:,app_password:,app_endPointUrl:,app_token_param:,baseUrl:,category:,tier:,tags:, header_1:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --delProject) PROJECT_DELETE_FLAG="$2"; shift;;
                    --profile) PROFILE_NAME="$2"; shift;;                    
                    --scanner) REGION="$2"; shift;;
                    --outputfile) OUTPUT_FILENAME="$2"; shift;;
		    
                    --emailReport) FX_EMAIL_REPORT="$2"; shift;;
                    --reportType) FX_REPORT_TYPE="$2"; shift;;

                    # To Fail script execution on Vulnerable severity
                    --fail-on-vuln-severity) FAIL_ON_VULN_SEVERITY="$2"; shift;;


                    # For Refreshing Project Playbooks
                    --refresh-playbooks) REFRESH_PLAYBOOKS="$2"; shift;;

                    # For Project Registeration via OpenSpecUrl
                    --openAPISpecUrl) OPEN_API_SPEC_URL="$2"; shift;;

                    # For Project Registeration via OpenSpecFile
                    --openAPISpecFile) openText="$2"; shift;;

                    # For Project Registeration via OpenSpecUrl
                    --internal_OpenAPISpecUrl) INTERNAL_OPEN_API_SPEC_URL="$2"; shift;;
                    --specType) SPEC_TYPE="$2"; shift;;

                    # For Project Profile To be Updated with a scanner
                    --profileScanner) PROFILE_SCANNER="$2"; shift;;
		    
                    # For Project Credentials Update
                    --envName) ENV_NAME="$2"; shift;;                        
                    --authName) AUTH_NAME="$2"; shift;;       
                    --app_username) APP_USER="$2"; shift;;
                    --app_password) APP_PWD="$2"; shift;; 
                    --app_endPointUrl) ENDPOINT_URL="$2"; shift;;
                    --app_token_param) TOKEN_PARAM="$2"; shift;;
                    --header_1) COMPLETE_HEADER1="$2"; shift;;
		    
		    # To update BaseUrl
                    --baseUrl) BASE_URL="$2"; shift;;

                    --category) CAT="$2"; shift;;
                    --tier) TIER="$2"; shift;;		    
                    --tags) FX_TAGS="$2"; shift;;		                    
                    --) shift;;
             esac
             shift;
    done

if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

if [ "$FX_PROJECT_NAME" != "" ]; then
      PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/-/ /g' | sed 's/@/ /g' | sed 's/#/ /g' |  sed 's/&/ /g' | sed 's/*/ /g' |  sed 's/(/ /g' | sed 's/)/ /g' | sed 's/=/ /g' | sed 's/+/ /g' | sed 's/~/ /g' | sed 's/\// /g' | sed 's/\\/ /g' | sed 's/\^/ /g' | sed 's/\;/ /g' | sed 's/\:/ /g' | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\./ /g' | sed 's/\,/ /g')
      FX_PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/ /%20/g' |  sed 's/-/%20/g' | sed 's/@/%20/g' | sed 's/#/%20/g' |  sed 's/&/%20/g' | sed 's/*/%20/g' |  sed 's/(/%20/g' | sed 's/)/%20/g' | sed 's/=/%20/g' | sed 's/+/%20/g' | sed 's/~/%20/g' | sed 's/\//%20/g' | sed 's/\\/%20/g' | sed 's/\^/%20/g' | sed 's/\;/%20/g' | sed 's/\:/%20/g' | sed 's/\[/%20/g' | sed 's/\]/%20/g' | sed 's/\./%20/g' | sed 's/\,/%20/g')
fi

if   [ "$PROFILE_NAME" == ""  ]; then
        PROFILE_NAME=Master
fi

FX_SCRIPT=""
if [ "$FX_TAGS" != "" ];
then
FX_SCRIPT="&tags=script:"+${FX_TAGS}
fi

# For Project Registeration via OpenSpecUrl
if   [ "$OPEN_API_SPEC_URL" == ""  ]; then
        OAS=false
else
        OAS=true

fi

# For Project Name exist check
if   [ "$FX_PROJECT_NAME" == ""  ]; then
        PROJECT_NAME_FLAG=false        
else 
        PROJECT_NAME_FLAG=true        
fi

# To check scanner exists
if   [ "$REGION" == ""  ]; then
        SCANNER_NAME_FLAG=false
else 
        SCANNER_NAME_FLAG=true         
fi

if [ "$PROJECT_DELETE_FLAG" == "" ]; then
      PROJECT_DELETE_FLAG=false
fi
tokenResp=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login )
tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | tr -d '{' | tr -d '}' | tr -d '"') 
if [ $tokenResp1 == "token" ];then
      token=$(echo $tokenResp | jq -r '.token')
      echo "generated token is:" $token
      echo " "  
elif [ $tokenResp1 == "message" ];then  
       message=$(echo $tokenResp | jq -r '.message')
       echo "$message. Please provide correct APIsec User Credentials!!"
       echo " "
       exit 1
fi





# To check Project Name existence 
if [ "$PROJECT_NAME_FLAG" = true ]; then
      dtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")                                                    
      errorsFlag=$(echo "$dtoData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$dtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
           echo $errMsg
           AUTOPILOT_SCAN_FLAG=false
           exit 1
      elif [ $errorsFlag = false ]; then            
            dto=$(echo "$dtoData" | jq -r '.data')
            PROJECT_ID=$(echo "$dto" | jq -r '.id')
            getProjectName=$(echo "$dtoData" | jq -r '.data.name')
            AUTOPILOT_SCAN_FLAG=true
      fi
fi 

# To check Project Name existence 
if [ "$AUTOPILOT_SCAN_FLAG" = true ]; then
      dtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/runs/project/${PROJECT_ID}?page=0" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
      errorsFlag=$(echo "$dtoData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$dtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
           echo $errMsg
           exit 1
      elif [ $errorsFlag = false ]; then  
            echo " "
            totalRunIds=$(echo "$dtoData" | jq -r '.totalElements')
            if [ $totalRunIds -eq 0 ]; then
                  echo "Total auto-pilots scans triggered are: $totalRunIds"
                  echo "Autopilot Scans didn't got triggered on $FX_PROJECT_NAME project, so breaking script execution!!"
                  exit 1
            else
                 echo "Total auto-pilots scans triggered are: $totalRunIds"
                 readarray -t dto < <(echo "$dtoData" | jq -c '.data[]')
                 for runId in "${dto[@]}"                               
                    do                                               
                         projectName=$(echo $runId | jq -r .job.project.name)
                         projectId=$(echo $runId | jq -r .job.project.id)
                         scannerName=$(echo $runId | jq -r .regions)
                         profileName=$(echo $runId | jq -r .job.name)          
                         profileId=$(echo $runId | jq -r .job.id)
                         environmentName=$(echo $runId | jq -r .job.environment.name)
                         environmentId=$(echo $runId | jq -r .job.environment.id)                         
                         runNumber=$(echo $runId | jq -r .runId)
                         runId1=$(echo $runId | jq -r .id)
                         scanStatus=$(echo $runId | jq -r .task.status)
                         time_millis=$(echo $runId | jq -r .task.totalTime)
                         totalTime=`echo "scale=2;${time_millis}/1000" | bc`                        
                         echo "Project-Name: $projectName"
                         echo "Project-ID: $projectId"
                         echo "Scanner-Name: $scannerName"
                         echo "Profile-Name: $profileName"
                         echo "Profile-Id: $profileId"
                         echo "Environment-Name: $environmentName"
                         echo "Environment-Id: $environmentId"
                         echo "Scan-No: $runNumber"
                         echo "Scan-RunId: $runId1"
                         echo "Scan-Status: $scanStatus"
                         echo "Scan-Total-Time: $totalTime seconds"
                         echo " "
                    done                
            fi     
      fi
fi 


echo "Script Execution is done!!"


# if [ "$PROJECT_DELETE_FLAG" = true ]; then

#       delProjData=$(curl -s -X DELETE "${FX_HOST}/api/v1/projects/$PROJECT_ID" -H --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
#       errorsFlag=$(echo "$delProjData" | jq -r '.errors')      
#       if [ $errorsFlag = true ]; then           
#              errMsg=$(echo "$delProjData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
#              #getProjectName=$(echo "$dtoData" | jq -r '.data.name')
#              #echo $getProjectName
#              echo $errMsg
#              exit 1
#       elif [ $errorsFlag = false ]; then            
#              echo "Successfully deleted '$FX_PROJECT_NAME' project!!"
#              exit 0
#       fi

# fi





#return 0
