#!/bin/bash
# Begin
#
#
#
# Script Purpose: This script will create a profile with a scanner name of an existing project.
#                 It also update scanner name of an existing profile of an existing project.
#
#                 Flow of the script is as such it will create a profile if one doesn't exist for a name passed with parameter(--profileName).
#                 But however if a profile with passed parameter(--profileName) already exist then script will update scanner name with the string passed with the parameter --scannerName.
# 
#
# How to run the this script.
# Use-Case 1: To create a profile with a configured scanner
# Syntax:        bash apisec-configure-profile-scanner.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --profileName <profileName-to-create-or-update> --scannerName <ScannerName> --envName <exiting-environmentName-to-use>   

# Example usage: bash apisec-configure-profile-scanner.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --profileName "QA"                              --scannerName "Super_1"     --envName "UAT"                                       

# Use-Case 2: To update a profile with a new scanner name
# Syntax:        bash apisec-configure-profile-scanner.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --profileName <profileName-to-create-or-update> --scannerName <ScannerName> 

# Example usage: bash apisec-configure-profile-scanner.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --profileName "QA"                              --scannerName "Super_1"     



TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profileName:,scannerName:,envName:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		            --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --profileName) PROFILE_NAME="$2"; shift;;                    
                    --scannerName) SCANNER_NAME="$2"; shift;;   
                    --envName) ENV_NAME="$2"; shift;;                                     
                    --) shift;;
             esac
             shift;
    done
    
if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

if   [ "$ENV_NAME" == ""  ]; then
        ENV_NAME=Master
fi


if    [ "$SCANNER_NAME" == ""  ] || [ "$PROFILE_NAME" == ""  ]; then
        PROFILE_SCANNER_FLAG=false
else 
        PROFILE_SCANNER_FLAG=true
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
       pdto=$(echo $dto |  tr -d ' ')
       #echo $getProjectName
fi

scanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer "$token"")
errorsFlag=$(echo "$scanData" | jq -r '.errors')      
if [ $errorsFlag = true ]; then           
      errMsg=$(echo "$scanData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')           
      echo $errMsg
      exit 1
elif [ $errorsFlag = false ]; then            
       scanCount=0            
       scanners_Names=$(jq -r '.data[].name' <<< "$scanData")            
       for sName in ${scanners_Names}
           do 
                if [ "$sName" == "$SCANNER_NAME" ]; then   
                         scanCount=`expr $scanCount + 1`  
                fi
           done
        superScanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters/superbotnetwork?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer "$token"")
        super_scanners_Names=$(jq -r '.data[].name' <<< "$superScanData")
         for sName in ${super_scanners_Names}
           do 
                if [ "$sName" == "$SCANNER_NAME" ]; then   
                         scanCount=`expr $scanCount + 1`  
                fi
           done
        if [ $scanCount -le 0 ]; then
            echo "$SCANNER_NAME scanner doesn't exists!!"
            exit 1
        fi

fi

# dto=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
# PROJECT_ID=$(echo "$dto" | jq -r '.id')

# pdto=$(echo $dto |  tr -d ' ')
if [ "$PROFILE_SCANNER_FLAG" = true ]; then
      data=$(curl -s --location --request GET "${FX_HOST}/api/v1/jobs/project-id/${PROJECT_ID}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC"  --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')

      prof_names=$(jq -r '.name' <<< "$data")
      prof_names_count=( $prof_names )
      prof_names_count=$(echo ${#prof_names_count[*]})

      lCount=0
      for prof in ${prof_names}
         do
            if [ "$PROFILE_NAME" != "$prof" ]; then
                  lCount=`expr $lCount + 1` 
            fi      
         done
      if [ $lCount -eq $prof_names_count ]; then      
            envData=$(curl -s --location --request GET "${FX_HOST}/api/v1/envs/projects/${PROJECT_ID}?page=0&pageSize=25" --header "Accept: application/json"  --header "accept: */*" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')
           for row in $(echo "${envData}" | jq -r '. | @base64'); 
               do
                  _jq() {
                        echo ${row} | base64 --decode | jq -r ${1}
                  }
                  envName=$(echo $(_jq '.') | jq  -r '.name')
                  envId=$(echo $(_jq '.') | jq  -r '.id')
                 
                  if [ "$ENV_NAME" == "$envName"  ]; then                 
                        echo "Creating $PROFILE_NAME profile with $SCANNER_NAME scanner in $FX_PROJECT_NAME project!!"
                        envID=$(echo "$envId")                                                       
                        #Data=$(curl -s --location --request POST "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"environment":{"auths":[],"baseUrl":"","id":"'${envID}'"},"tags":[],"regions":"'${SCANNER_NAME}'","issueTracker":{},"project": '${pdto}',"logPolicy":"DEBUG","timeZone":"","name":"'${PROFILE_NAME}'","cron":"","categories":""}' | jq -r '.data')
                        profData=$(curl -s --location --request POST "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"environment":{"auths":[],"baseUrl":"","id":"'${envID}'"},"tags":[],"regions":"'${SCANNER_NAME}'","issueTracker":{},"project": '${pdto}',"logPolicy":"DEBUG","timeZone":"","name":"'${PROFILE_NAME}'","cron":"","categories":""}')
                        uErrorsFlag=$(echo $profData | jq -r '.errors')
                        if [ $uErrorsFlag = true ]; then     
                              errMsg=$(echo "$profData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                              
                              echo $errMsg
                              exit 1
                        elif [ $uErrorsFlag = false ]; then 
                               Data=$(echo "$profData" | jq -r '.data')
                               profileScanner=$(echo "$Data" | jq -r '.regions')
                               profID=$(echo "$Data" | jq -r '.id')                     
                               echo " "
                               echo "ProjectName: $FX_PROJECT_NAME"
                               echo "ProjectId: $PROJECT_ID"
                               echo "EnvironmentName: $envName"
                               echo "EnvironmentId: $envId"                            
                               echo "ProfileName: $PROFILE_NAME"
                               echo "ProfileId: $profID"
                               echo "ProfileScannerName: $profileScanner"
                               echo " "                 
                        fi

                  fi
               done

      else
           for row in $(echo "${data}" | jq -r '. | @base64'); 
               do
                   _jq() {
                         echo ${row} | base64 --decode | jq -r ${1}
                   }
                   profName=$(echo $(_jq '.') | jq  -r '.name')
                   profId=$(echo $(_jq '.') | jq  -r '.id')     
                   if [ "$PROFILE_NAME" == "$profName"  ]; then
                         echo "Updating $PROFILE_NAME profile with $SCANNER_NAME scanner in $FX_PROJECT_NAME project!!"
                         udto=$(echo $(_jq '.') | jq '.regions = "'${SCANNER_NAME}'"')
                         envId=$(echo $(_jq '.') | jq '.environment.id')
                         envName=$(echo $(_jq '.') | jq '.environment.name')
                         #updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data')
                         updatedProfData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto")
                         uErrorsFlag=$(echo $updatedProfData | jq -r '.errors')
                         if [ $uErrorsFlag = true ]; then     
                              errMsg=$(echo "$updatedProfData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')                                                                  
                              echo $errMsg
                              exit 1
                         elif [ $uErrorsFlag = false ]; then
                                updatedData=$(echo "$updatedProfData" | jq -r '.data')
                                updatedScanner=$(echo "$updatedData" | jq -r '.regions')                     
                                echo " "
                                echo "ProjectName: $FX_PROJECT_NAME"
                                echo "ProjectId: $PROJECT_ID"
                                echo "EnvironmentName: $envName"
                                echo "EnvironmentId: $envId"                          
                                echo "ProfileName: $PROFILE_NAME"
                                echo "ProfileId: $profId"
                                echo "UpdatedScannerName: $updatedScanner"
                                echo " "                 
                         fi
                     

                   fi
               done
      
      fi
fi
echo "Script Execution is finished."