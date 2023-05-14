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
    
#FX_USER=$1
#FX_PWD=$2
#FX_JOBID=$3
#REGION=$4
#FX_ENVID=$5
#FX_PROJECTID=$6
#FX_EMAIL_REPORT=$7
#FX_TAGS=$8

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
#tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | cut -d{ -f1 | cut -d} -f2 | cut -d'"' -f2)
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


# For Project Registeration via OpenSpecUrl
if [ "$OAS" = true ]; then

     getProjectName=$(curl -s -X GET "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" -H "accept: */*"  --header "Authorization: Bearer "$token"" | jq -r '.data|.name')
     if [ "$getProjectName" == null ];then
                echo "Registering Project '${PROJECT_NAME}' via OpenAPISpecUrl method!!"
                echo ' '
                response=$(curl -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'"${PROJECT_NAME}"'","openAPISpec":"'${OPEN_API_SPEC_URL}'","planType":"ENTERPRISE","isFileLoad": false,"source":"FILE","personalizedCoverage":{"auths":[]}}')
                message=$(jq -r '.messages[].value' <<< "$response")                                          
                data=$(jq -r '.data' <<< "$response")
                project_name=$(jq -r '.name' <<< "$data")
                project_id=$(jq -r '.id' <<< "$data")

                sleep 5                
                if [ -z "$project_id" ] || [  "$project_id" == null ]; then
                        echo "Project Id is $project_id/empty" > /dev/null
                        echo "Error Message: $message"
                        echo " "
                        exit 1
                else
                        playbookTaskStatus="In_progress"
                        echo "playbookTaskStatus = " $playbookTaskStatus
                        retryCount=0
                        pCount=0

                        while [ "$playbookTaskStatus" == "In_progress" ] || [ "$playbookTaskStatus" == null ]
                                 do
                                      #if [ $pCount -eq 0 ]; then
                                      pCount=`expr $pCount + 1`
                                      echo "Checking playbooks generate task Status: $playbookTaskStatus Count No: $pCount"
                                      echo " "                                                                              
                                      retryCount=`expr $retryCount + 1`  
                                      sleep 5

                                      playbookTaskStatus=$(curl -s -X GET "${FX_HOST}/api/v1/events/project/${project_id}/Sync" -H "accept: */*" -H "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '."data".status')
                                      if [ "$playbookTaskStatus" == "Done" ]; then
                                            echo " "
                                            echo "Playbooks generation task for the registered project '$PROJECT_NAME' is succesfully completed!!!"                                 
                                            echo "ProjectName: '$project_name'"
                                            echo "ProjectId: $project_id"
                                            echo 'Script Execution is Done.'
                                            exit 0
                                      fi

                                      if [ $retryCount -ge 60  ]; then
                                           echo " "
                                           #retryCount=`expr $retryCount \* 2`
                                           retryCount=`expr $retryCount \* 5`
                                           minutes=`expr $retryCount \/ 60`
                                           echo "Playbooks Generation Task Status is $playbookTaskStatus even after $retryCount seconds or $minutes minutes, so halting/breaking script execution!!!"
                                           exit 1
                                      fi
                                 done                        
                fi   
     elif [ "$getProjectName" == "$PROJECT_NAME" ];then
             echo "Project '${PROJECT_NAME}' already exists!!"      
             PROJECT_DELETE_FLAG=false 
     fi
    
fi


# To check Project Name existence 
if [ "$PROJECT_NAME_FLAG" = true ]; then
      dtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
      errorsFlag=$(echo "$dtoData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$dtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
           #getProjectName=$(echo "$dtoData" | jq -r '.data.name')
           #echo $getProjectName
           echo $errMsg
           exit 1
      elif [ $errorsFlag = false ]; then            
            dto=$(echo "$dtoData" | jq -r '.data')
            PROJECT_ID=$(echo "$dto" | jq -r '.id')
            getProjectName=$(echo "$dtoData" | jq -r '.data.name')
            #echo $getProjectName
      fi
fi 

# To check Scanner Name existence
if [ "$SCANNER_NAME_FLAG" = true ]; then      
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
                   if [ "$sName" == "$REGION" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done
            superScanData=$(curl -s --location --request GET "$FX_HOST/api/v1/bot-clusters/superbotnetwork?page=0&pageSize=20&sort=createdDate&sortType=DESC"  --header "Authorization: Bearer "$token"")
            super_scanners_Names=$(jq -r '.data[].name' <<< "$superScanData")
            for sName in ${super_scanners_Names}
               do 
                   if [ "$sName" == "$REGION" ]; then   
                         scanCount=`expr $scanCount + 1`  
                   fi
               done

            if [ $scanCount -le 0 ]; then
                 echo "$REGION scanner doesn't exists!!"
                 exit 1
            fi

      fi
fi




if [ "$PROJECT_DELETE_FLAG" = true ]; then

      delProjData=$(curl -s -X DELETE "${FX_HOST}/api/v1/projects/$PROJECT_ID" -H --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
      errorsFlag=$(echo "$delProjData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
             errMsg=$(echo "$delProjData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')
             #getProjectName=$(echo "$dtoData" | jq -r '.data.name')
             #echo $getProjectName
             echo $errMsg
             exit 1
      elif [ $errorsFlag = false ]; then            
             echo "Successfully deleted '$FX_PROJECT_NAME' project!!"
             exit 0
      fi

fi




if [ "$PROFILE_NAME" == "Super" ]; then
      data=$(curl -s --location --request GET "${FX_HOST}/api/v1/jobs/project-id/${PROJECT_ID}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC"  --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[]')
      ProfNames=$(echo $data | jq -r '.name')
         for pName in ${ProfNames}
               do 
                     if [ "$pName" == "Tier_0" ] || [ "$pName" == "Tier_1" ] || [ "$pName" == "Tier_2" ] || [ "$pName" == "Tier_3" ]; then   
                           URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${pName}&region=${REGION}&categories=${CAT}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" 
                           url=$( echo "$URL" | sed 's/ /%20/g' )
                           echo "The request is $url"
                           echo " "
                           data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]')
                           runId=$( jq -r '.id' <<< "$data")
                           projectId=$( jq -r '.job.project.id' <<< "$data")
                           echo "runId =" $runId
                           if [ "$runId" == null ]
                           then
                                     echo "RunId = " "$runId"
                                     echo "Invalid runid"
                                     echo $(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${pName}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
                                     exit 1
                           fi
                           taskStatus="WAITING"
                           echo "taskStatus = " $taskStatus

                           while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
                                    do
                                           sleep 5
                                           echo "Checking Status...."

                                           passPercent=$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

                                                   IFS=':' read -r -a array <<< "$passPercent"

                                                   taskStatus="${array[0]}"

                                                   echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"
                                                   # VAR2=$(echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}")      


                                          if [ "$taskStatus" == "COMPLETED" ];then
                                                echo "------------------------------------------------"
                                                #echo  "Run detail link ${FX_HOST}/${array[7]}"
                                                echo  "Run detail link ${FX_HOST}${array[7]}"
                                                echo "-----------------------------------------------"
                                                echo "$pName Profile Categories Scan Successfully Completed!!"
                                                echo " "
                                                if [ "$FX_EMAIL_REPORT" = true ]; then     
                                                      sleep 10
                                                      echo "Will wait for 10 seconds"                       
                                                      totalEScount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}/test-suite-responses" -H "accept: */*"  --header "Authorization: Bearer "$token""  | jq -r '.data[]|.id')
                                                      totalPGcount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}" -H "accept: */*"  --header "Authorization: Bearer "$token""  | jq -r '.data.task.totalTests')
                                                      esCount=0
                                                      for scan in ${totalEScount}
                                                          do
                                                                escount=`expr $escount + 1`
                                                          done
                                                      if [ $totalPGcount -eq $escount ]; then
                                                           echo "Email report will be sent in a short while!!"
                                                      else
                                                           echo "Email report will be sent after some delay!!"
                                                      fi
                                                fi

                                          fi
                                    done
                     fi
               done

         if [ "$OUTPUT_FILENAME" != "" ];then
               sarifoutput=$(curl -s --location --request GET "${FX_HOST}/api/v1/projects/${PROJECT_ID}/sarif" --header "Authorization: Bearer "$token"" | jq  '.data')
	         #echo $sarifoutput >> $OUTPUT_FILENAME
               echo $sarifoutput >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
               echo "SARIF output file created successfully"
               echo " "
         fi

         if [ "$FAIL_ON_VULN_SEVERITY_FLAG" = true ]; then
                severity=$(curl -s -X GET "${FX_HOST}/api/v1/projects/${PROJECT_ID}/vulnerabilities?&severity=All&page=0&pageSize=20" -H "accept: */*"  "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[] | .severity')
                cVulCount=0
                for vul in ${severity}
                    do
                                               
                        if [ "$vul" == "Critical"  ]; then
                                               
                              cVulCount=`expr $cVulCount + 1`                                           
                        fi
                    done
                echo "Found $cVulCount Critical Severity Vulnerabilities!!!"
                echo " "

                hVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "High"  ]; then
                              hVulCount=`expr $hVulCount + 1`                                           
                                          
                        fi

                    done
                echo "Found $hVulCount High Severity Vulnerabilities!!!"
                echo " "

                majVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "Major"  ]; then
                                                
                              majVulCount=`expr $majVulCount + 1`
                        fi
                                          
                    done
                echo "Found $majVulCount Major Severity Vulnerabilities!!!"
                echo " "

                medVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "Medium"  ]; then
                                                
                              medVulCount=`expr $medVulCount + 1`
                        fi
                                          
                    done
                echo "Found $medVulCount Medium Severity Vulnerabilities!!!"
                echo " "

                minVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "Minor"  ]; then
                                                
                              minVulCount=`expr $minVulCount + 1`
                        fi
                                          
                    done
                echo "Found $minVulCount Minor Severity Vulnerabilities!!!"
                echo " "

                lowVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "Low"  ]; then

                              lowVulCount=`expr $lowVulCount + 1`  
                                          
                        fi
                                          
                    done
                echo "Found $lowVulCount Low Severity Vulnerabilities!!!"
                echo " "

                triVulCount=0
                for vul in ${severity}
                    do
                                                
                        if [ "$vul" == "Trivial"  ]; then
                                               
                              triVulCount=`expr $triVulCount + 1` 
                                           
                        fi
                                          
                    done
                echo "Found $triVulCount Trivial Severity Vulnerabilities!!!"
                echo " "                                                        
                case "$FAIL_ON_VULN_SEVERITY" in 
                      "Critical") for vul in ${severity}
                                      do
                         
                                          if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                 echo "Failing script execution since we have found $cVulCount Critical severity vulnerabilities!!!"
                                                 exit 1                                           
                                          fi                                             
                                      done
                      ;;
                      "High") for vul in ${severity}
                                  do
                                                     
                                      if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                             echo "Failing script execution since we have found $cVulCount Critical and $hVulCount High severity vulnerabilities!!!"
                                             exit 1
                                           
                                      fi                                             
                                  done
                      ;;                     
                      "Medium") for vul in ${severity}
                                    do
                                                
                                        if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] || [ "$vul" == "Medium"  ] ; then
                                               echo "Failing script execution since we have found $cVulCount Critical, $hVulCount High and $medVulCount Medium severity vulnerabilities!!!"
                                               exit 1
                                           
                                        fi                                             
                                    done
                       ;;
                       *)                          
                esac

         fi 
         
         if [ "$taskStatus" == "TIMEOUT" ];then
               echo "Task Status = " $taskStatus
               exit 1
         fi
         exit 0
         #echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
         #exit 1

else
      URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${PROFILE_NAME}&region=${REGION}&categories=${CAT}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" 
      url=$( echo "$URL" | sed 's/ /%20/g' )
      echo "The request is $url"
      echo " "
      data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]')  
      # data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]')
      runId=$( jq -r '.id' <<< "$data")
      projectId=$( jq -r '.job.project.id' <<< "$data")
      #runId=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')

      echo "runId =" $runId
      #if [ -z "$runId" ]
      if [ "$runId" == null ]
      then
            echo "RunId = " "$runId"
            echo "Invalid runid"
            echo $(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${PROFILE_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
            exit 1
      fi


      taskStatus="WAITING"
      echo "taskStatus = " $taskStatus
      retryCount=0
      while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
               do
                             sleep 5
                             echo "Checking Status...."

                             passPercent=$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

                             IFS=':' read -r -a array <<< "$passPercent"

                             taskStatus="${array[0]}"

                             echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"
                             # VAR2=$(echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}")      


                             if [ "$taskStatus" == "COMPLETED" ];then
                                    echo "------------------------------------------------"
                                    #echo  "Run detail link ${FX_HOST}/${array[7]}"
                                    echo  "Run detail link ${FX_HOST}${array[7]}"
                                    echo "-----------------------------------------------"
                                    echo "$PROFILE_NAME Profile Catgories Scan Successfully Completed!!"
                                    echo " "
                                    if [ "$FX_EMAIL_REPORT" = true ]; then     
                                          sleep 10
                                          echo "Will wait for 10 seconds"                       
                                          totalEScount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}/test-suite-responses" -H "accept: */*"  --header "Authorization: Bearer "$token""  | jq -r '.data[]|.id')
                                          totalPGcount=$(curl -s -X GET "${FX_HOST}/api/v1/runs/${runId}" -H "accept: */*"  --header "Authorization: Bearer "$token""  | jq -r '.data.task.totalTests')
                                          esCount=0 
                                          for scan in ${totalEScount}
                                              do
                                                   escount=`expr $escount + 1`
                                              done
                                          if [ $totalPGcount -eq $escount ]; then
                                                echo "Email report will be sent in a short while!!"
                                          else
                                                echo "Email report will be sent after some delay!!"
                                          fi
                                    fi



                             fi
                            retryCount=`expr $retryCount + 1`  
                            #sleep 2
                            if [ $retryCount -ge 60  ]; then
                                  echo " "
                                  retryCount=`expr $retryCount \* 5`
                                  minutes=`expr $retryCount \/ 60`  
                                  echo "Triggered Scan Status is still '$taskStatus' even after $retryCount seconds or $minutes minutes for the runID: $runId in project '$FX_PROJECT_NAME' with '$PROFILE_NAME' profile and '$REGION' scanner, so halting script execution!!!"
                                  exit 1
                            fi
               done

      if [ "$taskStatus" == "TIMEOUT" ];then
            echo "Task Status = " $taskStatus
            exit 1
      fi

      echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
      exit 1
fi 
#return 0
