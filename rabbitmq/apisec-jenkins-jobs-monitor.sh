#!/bin/bash
# Begin

# Script Purpose: This script will automatically trigger jobs/builds on APIsec jenkins platform(http://jenkins.apisec.ai:8080) for git changes in Fxt github repository.
#
#
# How to run the this script.
# Syntax:        bash apisec-jenkins-jobs-monitor.sh --username "<username>"       --api-token "<password>"  --host "<jenkins-url>"

# Example usage: bash apisec-jenkins-jobs-monitor.sh --username "admin@apisec.ai"  --api-token "apisec@5421" --host "http://jenkins.apisec.ai:8080"

TEMP=$(getopt -n "$0" -a -l "host:,username:,api-token:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --api-token) FX_PWD="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

joblist="Super-1
Super-2
Super-3
Super-4
US-EAST-1
US-WEST-1
US-WEST-2"
#PlaybookGenTest"
#echo "$joblist"
jobsFailCount=0
for job in ${joblist}
    do
         url=$(curl -s -X GET -u $FX_USER:$FX_PWD $FX_HOST/view/Scanning-PlaybookGen/job/$job/api/json | jq -r '.lastBuild.url')         
         result=$(curl -s -X GET -u $FX_USER:$FX_PWD $url/api/json | jq -r '.result')
         echo $url
         echo $result
         echo " "

         if [ "$result" == "FAILURE" ]; then
                jobsFailCount=`expr $jobsFailCount + 1`
                echo "JobBuildNumberUrl: $url"
                echo "JobBuildNumberResult: $result"
                echo " "
         fi

    done

if [ $jobsFailCount -eq 7 ]; then
    
      echo "No. of failed scanning jobs are: $jobsFailCount"
      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/{JOB_NAME}/build
      exit 1
else 
       echo "No. of failed scanning jobs are: $jobsFailCount"  
fi
