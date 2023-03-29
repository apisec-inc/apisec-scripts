#!/bin/bash
# Begin

# Script Purpose: This script will automatically trigger jobs/builds on APIsec jenkins platform(http://jenkins.apisec.ai:8080) for git changes in Fxt github repository.
#
#
# How to run the this script.
# Syntax:        bash apisec-jenkins-ci-cd.sh --username "<username>"       --api-token "<password>"  --host "<jenkins-url>"

# Example usage: bash apisec-jenkins-ci-cd.sh --username "admin@apisec.ai"  --api-token "apisec@5421" --host "http://jenkins.apisec.ai:8080"

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

cd Code-Checkin-master

joblist=$(git diff @^1 --name-only | cut -d/ -f1 | sort -u)
joblist1=$(git diff --name-only @^1 -- Web | cut -d/ -f1 | sort -u)



apigatewayJobCount=0
awsJobCount=0
cpJobCount=0
emailJobCount=0
itJobCount=0
githubJobCount=0
jiraJobCount=0
reportsJobCount=0
slackJobCount=0
vcgitJobCount=0
tJobCount=0

echo "$joblist"
echo " "
sleep 5
for job in ${joblist}
    do
                        if [[ $job == *"DTO"* ]]; then
                                echo "Building all 10 jobs"
                                echo " "

                                if [ $apigatewayJobCount -eq 0 ]; then
                                      echo "Building Api-Gateway-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Api-Gateway-Skill/build
                                      echo " "
                                      apigatewayJobCount=`expr $apigatewayJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $awsJobCount -eq 0 ]; then
                                      echo "Building Cloud-Aws-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Cloud-Aws-Skill/build
                                      echo " "
                                      awsJobCount=`expr $awsJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi


                                if [ $itJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Fx-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Fx-Issue-Tracker/build
                                      echo " "
                                      itJobCount=`expr $itJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $githubJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Github-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Github-Issue-Tracker/build
                                      echo " "
                                      githubJobCount=`expr $githubJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $jiraJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Jira-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Jira-Issue-Tracker/build
                                      echo " "
                                      jiraJobCount=`expr $jiraJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $emailJobCount -eq 0 ]; then
                                      echo "Building Notification-Email-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Email-Notification/build
                                      echo " "
                                      emailJobCount=`expr $emailJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $slackJobCount -eq 0 ]; then
                                      echo "Building Notification-Slack-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Slack-Notification/build
                                      echo " "
                                      slackJobCount=`expr $slackJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $reportsJobCount -eq 0 ]; then
                                      echo "Building Reports job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Reports/build
                                      echo " "
                                      reportsJobCount=`expr $reportsJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $vcgitJobCount -eq 0 ]; then
                                      echo "Building VC-Git-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/VC-Git/build
                                      echo " "
                                      vcgitJobCount=`expr $vcgitJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                                if [ $cpJobCount -eq 0 ]; then  

                                      #WebChange=$(git diff @^1 --name-only | grep Web | cut -d/ -f1 | sort -u)
                                      tsChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep ts)
                                      htmlChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep html)
                                      scssChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep scss)
                                      echo "$tsChanges"
                                      echo "$htmlChanges"
                                      echo "$scssChanges"


                                     if [[ $tsChanges == *"ts"* ]] || [[ $htmlChanges == *"html"* ]] || [[ $scssChanges == *"scss"* ]]; then
                                            echo "Building NG-Build job"
                                            curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Ng-Build/build
                                            echo " "
                                            cpJobCount=`expr $cpJobCount + 1`
                                            tJobCount=`expr $tJobCount + 1`                                                            
                                            #break; 
                                     

                                     else       
                                            echo "Building Control-Plane job"
                                            curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Control-Plane/build
                                            echo " "
                                            cpJobCount=`expr $cpJobCount + 1`
                                            tJobCount=`expr $tJobCount + 1`         
                                     fi 
                                fi                                

                                echo "Total no. of jobs triggered/build are: $tJobCount"

                                exit 0
                        elif [[ $job == *"Api-Gateway-Skill"* ]]; then
                                if [ $apigatewayJobCount -eq 0 ]; then
                                      echo "Building Api-Gateway-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Api-Gateway-Skill/build
                                      echo " "
                                      apigatewayJobCount=`expr $apigatewayJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Cloud-Aws-Skill"* ]] || [[ $job == *"Cloud-Skill-Kit"* ]] ; then
                                if [ $awsJobCount -eq 0 ]; then
                                      echo "Building Cloud-Aws-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Cloud-Aws-Skill/build
                                      echo " "
                                      awsJobCount=`expr $awsJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Web"* ]] || [[ $job == *"Converter"* ]] || [[ $job == *"REST"* ]] || [[ $job == *"REST-SDK"* ]] || [[ $job == *"Services"* ]] || [[ $job == *"DAO"* ]]; then
                                if [ $cpJobCount -eq 0 ]; then  

                                      #WebChange=$(git diff @^1 --name-only | grep Web | cut -d/ -f1 | sort -u)
                                      tsChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep ts)
                                      htmlChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep html)
                                      scssChanges=$(git diff @^1 --name-only | grep ui | cut -d. -f3 | sort -u | grep scss)
                                      echo "$tsChanges"
                                      echo "$htmlChanges"
                                      echo "$scssChanges"


                                     if [[ $tsChanges == *"ts"* ]] || [[ $htmlChanges == *"html"* ]] || [[ $scssChanges == *"scss"* ]]; then
                                            echo "Building NG-Build job"
                                            curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Ng-Build/build
                                            echo " "
                                            cpJobCount=`expr $cpJobCount + 1`
                                            tJobCount=`expr $tJobCount + 1`                                                            
                                            #break; 
                                     

                                     else       
                                            echo "Building Control-Plane job"
                                            curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Control-Plane/build
                                            echo " "
                                            cpJobCount=`expr $cpJobCount + 1`
                                            tJobCount=`expr $tJobCount + 1`         
                                     fi 
                                fi
                        elif [[ $job == *"Issue-Tracker-Fx-Skill"* ]]; then
                                if [ $itJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Fx-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Fx-Issue-Tracker/build
                                      echo " "
                                      itJobCount=`expr $itJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Issue-Tracker-Github-Skill"* ]]; then
                                if [ $githubJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Github-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Github-Issue-Tracker/build
                                      echo " "
                                      githubJobCount=`expr $githubJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1` 
                                fi
                        elif [[ $job == *"Issue-Tracker-Jira-Skill"* ]] || [[ $job == *"Issue-Tracker-Skill-Kit"* ]]; then
                                if [ $jiraJobCount -eq 0 ]; then
                                      echo "Building Issue-Tracker-Jira-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Jira-Issue-Tracker/build
                                      echo " "
                                      jiraJobCount=`expr $jiraJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Notification-Email-Skill"* ]]; then
                                if [ $emailJobCount -eq 0 ]; then
                                      echo "Building Notification-Email-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Email-Notification/build
                                      echo " "
                                      emailJobCount=`expr $emailJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Notification-Slack-Skill"* ]]; then 
                                if [ $slackJobCount -eq 0 ]; then
                                      echo "Building Notification-Slack-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Slack-Notification/build
                                      echo " "
                                      slackJobCount=`expr $slackJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi
                        elif [[ $job == *"Reports"* ]]; then 
                                if [ $reportsJobCount -eq 0 ]; then
                                      echo "Building Reports job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Reports/build
                                      echo " "
                                      reportsJobCount=`expr $reportsJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                        elif [[ $job == *"VC-Git-Skill"* ]] || [[ $job == *"VC-Skill-Kit"* ]] || [[ $job == *"Codegen"* ]]; then
                                if [ $vcgitJobCount -eq 0 ]; then
                                      echo "Building VC-Git-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/VC-Git/build
                                      echo " "
                                      vcgitJobCount=`expr $vcgitJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`
                                fi

                        else
                              echo " No changes are there to build jobs" > /dev/null

                        fi

    done

    echo "Total no. of jobs triggered/build are: $tJobCount"

    exit 0

