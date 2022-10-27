#!/bin/bash
# Begin
TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profile:,scanner:,emailReport:,reportType:,tags:,fail-on-high-vulns:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --profile) JOB_NAME="$2"; shift;;
                    --scanner) REGION="$2"; shift;;
                    --emailReport) FX_EMAIL_REPORT="$2"; shift;;
                    --reportType) FX_REPORT_TYPE="$2"; shift;;
                    --fail-on-high-vulns) FAIL_ON_HIGH_VULNS="$2"; shift;;
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

FX_SCRIPT=""
if [ "$FX_TAGS" != "" ];
then
FX_SCRIPT="&tags=script:"+${FX_TAGS}
fi

if   [ "$FAIL_ON_HIGH_VULNS" == ""  ]; then
        FAIL_ON_HIGH_VULNS=false
fi
token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login | jq -r .token)

#echo "generated token is:" $token

URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}"

url=$( echo "$URL" | sed 's/ /%20/g' )
data=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]')
runId=$( jq -r '.id' <<< "$data")
projectId=$( jq -r '.job.project.id' <<< "$data")
#runId=$(curl -s --location --request POST "$url" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')

echo "runId =" $runId
if [ -z "$runId" ]
then
          echo "RunId = " "$runId"
          echo "Invalid runid"
          echo $(curl -s --location --request POST "${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
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
                       # echo  "Run detail link ${FX_HOST}/${array[7]}"
                        echo  "Run detail link ${FX_HOST}${array[7]}"
                        echo "-----------------------------------------------"
                        echo "Scan Successfully Completed"
                        if [ "$FAIL_ON_HIGH_VULNS" = true ]; then
                              severity=$(curl -s -X GET "${FX_HOST}/api/v1/projects/${projectId}/vulnerabilities?&severity=All&page=0&pageSize=20" -H "accept: */*"  "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data[] | .severity')

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

                                vCount=1
                                for vul in ${severity}
                                    do
                                                
                                          if  [ "$vul" == "Critical"  ] || [ "$vul" == "High"  ] ; then
                                                 echo "Failing script execution since we found "$vul" vulnerability!!!"
                                                 exit 1
                                           
                                          fi
                                          vCount=`expr $vCount + 1`
                                    done
                            
                            
                        fi 
                        exit 0

                fi
        done

if [ "$taskStatus" == "TIMEOUT" ];then
echo "Task Status = " $taskStatus
 exit 1
fi

echo "$(curl -s --location --request GET "${FX_HOST}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
exit 1

return 0
