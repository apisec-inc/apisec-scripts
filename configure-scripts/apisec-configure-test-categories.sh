#!/bin/bash
# Begin
#
#
#
# Script Purpose: This script will create a profile as well as select some test categories based on the tier used of an existing project on APIsec platform.
#                 It will also update test categories of an existing profile.
#               
#                 Tier0 has these categories: ABAC_Level1,ABAC_Level2,InvalidAuth,InvalidAuthEmpty,InvalidAuthSQL
#                 
#                 Tier1 has these categories: Unsecured,cors_config,disable_user_after_5_failed_login_attempts,error_logging,Excessive_Data_Exposure,Incremental_Ids
# 
#
# How to run the this script.
# Use-Case 1: To create a profile along with few test categories.
# Syntax:        bash apisec-configure-test-categories.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --profileName <profileName-to-create-or-update> --tier <tierType> --envName <exiting-environmentName-to-use>   

# Example usage: bash apisec-configure-test-categories.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --profileName "QA"                              --tier "tier0"    --envName "UAT"                                       

# Use-Case 2: To update a profile with a differnent tier of test categories
# Syntax:        bash apisec-configure-test-categories.sh --host "<Hostname or IP>"         --username "<username>"      --password "<password>"    --project "<projectname>" --profileName <profileName-to-create-or-update> --tier <tierType>

# Example usage: bash apisec-configure-test-categories.sh --host "https://cloud.apisec.ai"  --username "admin@apisec.ai" --password "apisec@5421"   --project "netbanking"    --profileName "QA"                              --tier "tier0"    



TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profileName:,tier:,envName:" -- -- "$@")

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
                    --tier) FX_TIER="$2"; shift;;   
                    --envName) ENV_NAME="$2"; shift;;                                     
                    --) shift;;
             esac
             shift;
    done
    
if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi

if [ "$FX_TIER" = "" ];then
        CAT_TIER=""
elif [ "$FX_TIER" = "tier0" ];then
        CAT_TIER="ABAC_Level1,ABAC_Level2,InvalidAuth,InvalidAuthEmpty,InvalidAuthSQL"    
elif [ "$FX_TIER" = "tier1" ];then
        CAT_TIER="Unsecured,cors_config,disable_user_after_5_failed_login_attempts,error_logging,Excessive_Data_Exposure,Incremental_Ids"        
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
                     if [ "$FX_TIER" != "" ]; then            
                           echo "Creating $PROFILE_NAME profile with $FX_TIER test categories in $FX_PROJECT_NAME project!!"
                           echo "$FX_TIER consists of these categories: $CAT_TIER "
                     fi
                     envID=$(echo "$envId")                                                       
                     Data=$(curl -s --location --request POST "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d '{"environment":{"auths":[],"baseUrl":"","id":"'${envID}'"},"tags":[],"regions":"","issueTracker":{},"project": '${pdto}',"logPolicy":"DEBUG","timeZone":"","name":"'${PROFILE_NAME}'","cron":"","categories":"'${CAT_TIER}'"}' | jq -r '.data')
                     updatedCategories=$(echo "$Data" | jq -r '.categories')
                     profID=$(echo "$Data" | jq -r '.id')                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "ProfileName: $PROFILE_NAME"
                     echo "ProfileId: $profID"
                     echo "UpdatedCategoriesList: $updatedCategories"
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
                     if [ "$FX_TIER" != "" ]; then
                           echo "Updating $PROFILE_NAME profile with $FX_TIER test categores in $FX_PROJECT_NAME project!!"
                           echo "$FX_TIER consists of these categories: $CAT_TIER "
                     fi
                     udto=$(echo $(_jq '.') | jq '.categories = "'${CAT_TIER}'"')
                     updatedData=$(curl -s --location --request PUT "${FX_HOST}/api/v1/jobs" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$udto" | jq -r '.data')
                     updatedCategories=$(echo "$updatedData" | jq -r '.categories')
                     
                     echo " "
                     echo "ProjectName: $FX_PROJECT_NAME"
                     echo "ProjectId: $PROJECT_ID"
                     echo "ProfileName: $PROFILE_NAME"
                     echo "ProfileId: $profId"
                     echo "UpdatedCategoriesList: $updatedCategories"
                     echo " "                 
                     

               fi
        done
      
fi

echo "Script Execution is finished."