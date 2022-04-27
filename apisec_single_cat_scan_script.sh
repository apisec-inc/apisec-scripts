#!/bin/bash
# Begin

# With this script we can sequentially triggered scans on UnSecured category of all projects of a user account.
# It will trigger one scan  per project on a particular page.

# How to run this script.
# Syntax:        bash apisec_single_cat_scan_script.sh  --username "<username>"           --password "<password>" --scanner "<scanner-name>" --hostname "<Hostname or IP>" --fromPage "<begin-page-no>" --toPage "<end-page-no>"
# Example usage: bash apisec_single_cat_scan_script.sh  --username "admin@apisec.ai"      --password "hello@234"  --scanner "us-west-1"      --hostname "20.99.193.218"    --fromPage "0"               --toPage "5"



TEMP=$(getopt -n "$0" -a -l "username:,password:,scanner:,hostname:,toPage:,fromPage:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --scanner) REGION="$2"; shift;;
                    --hostname) FX_HOSTNAME="$2"; shift;;
                    --fromPage) PAGE="$2"; shift;;
                    --toPage) PAGES="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

token=$(curl -s -k -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' https://${FX_HOSTNAME}/login | jq -r .token)
#echo "generated token is:" $token
tscancount=0
scancount=0
string1=$(date -u | awk '{print $4}')
while [ $PAGE -le $PAGES ]
do
   projectIds=$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/projects/myProjects?page=${PAGE}&pageSize=3" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.[]|.| .name + " " + .id')
   echo " "
   echo "Scanning will be triggered on the following projects of ${PAGE} page of the ${FX_USER} user account!!!"
   echo "-----------------------------------------------"
   echo "$projectIds"
   echo "-----------------------------------------------"
   projectnames=$(echo "$projectIds" | awk '{print $1}')
   projectids=$(echo "$projectIds" | awk '{print $2}')
   count=0
   for i in ${projectids}
   do
   
     SECONDS=0
     count=`expr $count + 1`
     scancount=`expr $scancount + 1`  
     echo " "
     echo "Scan No: ${scancount}"
     echo "Projects Page ${PAGE} Iteration. count No: ${count}"
     echo "ProjectID: "${i}""
     jobID=$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/jobs/project-id/${i}?page=0&pageSize=10" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.[].id')
     envID=$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/jobs/project-id/${i}?page=0&pageSize=10" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.[]|.environment|.id')
     echo "envID: $envID"
     echo "JobID: $jobID"
     #runId=$(curl -s -k --location --request POST "https://${FX_HOSTNAME}/api/v1/runs/job/${jobID}?region=${REGION}&tags=&suites=&categories=ABAC_Level1,%20ABAC_Level2,%20ABAC_Level3,%20ABAC_Level4,%20ABAC_Level5,%20ABAC_Level6,%20InvalidAuth,%20InvalidAuthEmpty,%20InvalidAuthSQL,%20ADoS,%20Incremental_Ids,%20NoSQL_Injection,%20SLA,%20RBAC,%20sql_injection_timebound,%20Sensitive_Data_Exposure,%20SimpleGET,%20NoSQL_Injection_Filter,%20sql_injection_filter,%20Unsecured,%20XSS_Injection,%20&emailReport=false&projectId=${i}&env=${envID}&endpoints=" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
     runId=$(curl -s -k --location --request POST "https://${FX_HOSTNAME}/api/v1/runs/job/${jobID}?region=${REGION}&tags=&suites=&categories=Unsecured%20&emailReport=false&projectId=${i}&env=${envID}&endpoints=" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
     echo "runId:" $runId
     if [ -z "$runId" ]
     then
          echo "RunId = " "$runId"
          echo "Invalid runid"
         # echo $(curl -k --location --request POST "https://${FX_HOSTNAME}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}" --header "Authorization: Bearer "$token"" | jq -r '.["data"]|.id')
         #exit 1
     fi
     taskStatus="WAITING"
     echo "taskStatus = " $taskStatus

     while [ "$taskStatus" == "WAITING" -o "$taskStatus" == "PROCESSING" ]
         do
                sleep 5
                 echo "Checking Status...."

                passPercent=$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token""| jq -r '.["data"]|.ciCdStatus')

                        IFS=':' read -r -a array <<< "$passPercent"

                        taskStatus="${array[0]}"

                        echo "Status =" "${array[0]}" " Success Percent =" "${array[1]}"  " Total Tests =" "${array[2]}" " Total Failed =" "${array[3]}" " Run =" "${array[6]}"



                if [ "$taskStatus" == "COMPLETED" ];then
            echo "------------------------------------------------"                       
                        echo  "Run detail link https://${FX_HOSTNAME}${array[7]}"
                        echo "-----------------------------------------------"
                        echo "Job run successfully completed"  
                        echo "-----------------------------------------------"                        
                        duration=$SECONDS
                        echo "It took $(($duration / 60)) minutes and $(($duration % 60)) seconds to complete the scan on ${i} project."
                        echo "-----------------------------------------------"
                        #exit 0                        

                fi
        done

     if [ "$taskStatus" == "TIMEOUT" ];then
        echo "Task Status = " $taskStatus
        echo "$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
        #exit 1
     fi

    #echo "$(curl -s -k --location --request GET "https://${FX_HOSTNAME}/api/v1/runs/${runId}" --header "Authorization: Bearer "$token"")"
    #exit 1
   done
   echo "Scanning on Projects of page ${PAGE} is completed."  
   echo "--------------------------------------------------"
   echo " "
   PAGE=`expr $PAGE + 1`
   tscancount=`expr $tscancount + $count`   
done
string2=$(date -u | awk '{print $4}')
StartDate=$(date -u -d "$string1" +"%s")
FinalDate=$(date -u -d "$string2" +"%s")
tDuration=$(date -u -d "0 $FinalDate sec - $StartDate sec" +"%H:%M:%S")
echo "Successfully triggered ${tscancount} scans in $tDuration duration on ${tscancount} projects of ${FX_HOSTNAME} environment!!!"

