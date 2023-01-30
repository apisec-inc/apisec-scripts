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

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

echo "generated token is:" $token
echo " "

dto=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
PROJECT_ID=$(echo "$dto" | jq -r '.id')

pdto=$(echo $dto |  tr -d ' ')

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
                     Data=$(curl -s --location --request POST "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"environment":{"auths":[],"baseUrl":"","id":"'${envID}'"},"tags":[],"regions":"'${SCANNER_NAME}'","issueTracker":{},"project": '${pdto}',"logPolicy":"DEBUG","timeZone":"","name":"'${PROFILE_NAME}'","cron":"","categories":""}' | jq -r '.data')
                     profileScanner=$(echo "$Data" | jq -r '.regions')
                     profID=$(echo "$Data" | jq -r '.id')                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "ProfileName: $PROFILE_NAME"
                     echo "ProfileId: $profID"
                     echo "ProfileScannerName: $profileScanner"
                     echo " "                 
                     

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
                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data')
                     updatedScanner=$(echo "$updatedData" | jq -r '.regions')
                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "ProfileName: $PROFILE_NAME"
                     echo "ProfileId: $profId"
                     echo "UpdatedScannerName: $updatedScanner"
                     echo " "                 
                     

               fi
        done
      
fi

echo "Script Execution is finished."