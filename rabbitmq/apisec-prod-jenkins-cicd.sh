#!/bin/bash
# Begin

# Script Purpose: This script will automatically trigger jobs/builds on APIsec jenkins platform(http://jenkins.apisec.ai:8080) for git changes in Fxt github repository.
#
#
# How to run the this script.
# Syntax:        bash prod-apisec-jenkins-ci-cd.sh --username "<username>"       --api-token "<password>"  --host "<jenkins-url>"

# Example usage: bash prod-apisec-jenkins-ci-cd.sh --username "admin@apisec.ai"  --api-token "apisec@5421" --host "http://jenkins.apisec.ai:8080"

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

tJobCount=0

                                      echo "Building Prod-API-Gateway job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-API-Gateway/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`

                                      echo "Building Prod-AWS-Skill job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-AWS-Skill/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`



                                      echo "Building Prod-Fx-Issue-Tracker job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Fx-Issue-Tracker/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`

                                      echo "Building Prod-Github-Issue-Tracker job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Github-Issue-Tracker/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`

                                      echo "Building Prod-Jira-Issue-Tracker job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Jira-Issue-Tracker/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`

                                      echo "Building Prod-Email-Notification job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Email-Notification/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`

                                      echo "Building Prod-Slack-Notification job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Slack-Notification/build
                                      echo " "
                                      slackJobCount=`expr $slackJobCount + 1`
                                      tJobCount=`expr $tJobCount + 1`


                                      echo "Building Prod-Reports job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Reports/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`



                                      echo "Building Prod-VC-Git job"
                                      curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-VC-Git/build
                                      echo " "
                                      tJobCount=`expr $tJobCount + 1`


                                            sleep 10

                                            echo "Building Prod-Control-Plane job"
                                            curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Control-Plane/build
                                            echo " "
                                            tJobCount=`expr $tJobCount + 1`                                      

                                echo "Total no. of jobs triggered/build are: $tJobCount"


#cd Code-Checkin-ReleaseBranch
# joblist=$(git diff @^1 --name-only | cut -d/ -f1 | sort -u)
# joblist1=$(git diff --name-only @^1 -- Web | cut -d/ -f1 | sort -u)



# apigatewayJobCount=0
# awsJobCount=0
# cpJobCount=0
# emailJobCount=0
# itJobCount=0
# githubJobCount=0
# jiraJobCount=0
# reportsJobCount=0
# slackJobCount=0
# vcgitJobCount=0
# tJobCount=0

# echo "$joblist"
# echo " "
# sleep 5
# for job in ${joblist}
#     do
#                         if [[ $job == *"DTO"* ]]; then
#                                 echo "Building all 10 jobs"
#                                 echo " "

#                                 if [ $apigatewayJobCount -eq 0 ]; then
#                                       echo "Building Prod-API-Gateway job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-API-Gateway/build
#                                       echo " "
#                                       apigatewayJobCount=`expr $apigatewayJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $awsJobCount -eq 0 ]; then
#                                       echo "Building Prod-AWS-Skill job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-AWS-Skill/build
#                                       echo " "
#                                       awsJobCount=`expr $awsJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi


#                                 if [ $itJobCount -eq 0 ]; then
#                                       echo "Building Prod-Fx-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Fx-Issue-Tracker/build
#                                       echo " "
#                                       itJobCount=`expr $itJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $githubJobCount -eq 0 ]; then
#                                       echo "Building Prod-Github-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Github-Issue-Tracker/build
#                                       echo " "
#                                       githubJobCount=`expr $githubJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $jiraJobCount -eq 0 ]; then
#                                       echo "Building Prod-Jira-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Jira-Issue-Tracker/build
#                                       echo " "
#                                       jiraJobCount=`expr $jiraJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $emailJobCount -eq 0 ]; then
#                                       echo "Building Prod-Email-Notification job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Email-Notification/build
#                                       echo " "
#                                       emailJobCount=`expr $emailJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $slackJobCount -eq 0 ]; then
#                                       echo "Building Prod-Slack-Notification job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Slack-Notification/build
#                                       echo " "
#                                       slackJobCount=`expr $slackJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $reportsJobCount -eq 0 ]; then
#                                       echo "Building Prod-Reports job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Reports/build
#                                       echo " "
#                                       reportsJobCount=`expr $reportsJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $vcgitJobCount -eq 0 ]; then
#                                       echo "Building Prod-VC-Git job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-VC-Git/build
#                                       echo " "
#                                       vcgitJobCount=`expr $vcgitJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                                 if [ $cpJobCount -eq 0 ]; then  
    
#                                             echo "Building Prod-Control-Plane job"
#                                             curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Control-Plane/build
#                                             echo " "
#                                             cpJobCount=`expr $cpJobCount + 1`
#                                             tJobCount=`expr $tJobCount + 1`         
#                                 fi                                

#                                 echo "Total no. of jobs triggered/build are: $tJobCount"

#                                 exit 0
#                         elif [[ $job == *"Api-Gateway-Skill"* ]]; then
#                                 if [ $apigatewayJobCount -eq 0 ]; then
#                                       echo "Building Prod-API-Gateway job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-API-Gateway/build
#                                       echo " "
#                                       apigatewayJobCount=`expr $apigatewayJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Cloud-Aws-Skill"* ]] || [[ $job == *"Cloud-Skill-Kit"* ]] ; then
#                                 if [ $awsJobCount -eq 0 ]; then
#                                       echo "Building Prod-AWS-Skill job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-AWS-Skill/build
#                                       echo " "
#                                       awsJobCount=`expr $awsJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Web"* ]] || [[ $job == *"Converter"* ]] || [[ $job == *"REST"* ]] || [[ $job == *"REST-SDK"* ]] || [[ $job == *"Services"* ]] || [[ $job == *"DAO"* ]]; then
#                                 if [ $cpJobCount -eq 0 ]; then        
#                                             echo "Building Prod-Control-Plane job"
#                                             curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Control-Plane/build
#                                             echo " "
#                                             cpJobCount=`expr $cpJobCount + 1`
#                                             tJobCount=`expr $tJobCount + 1`         
#                                 fi
#                         elif [[ $job == *"Issue-Tracker-Fx-Skill"* ]]; then
#                                 if [ $itJobCount -eq 0 ]; then
#                                       echo "Building Prod-Fx-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Fx-Issue-Tracker/build
#                                       echo " "
#                                       itJobCount=`expr $itJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Issue-Tracker-Github-Skill"* ]]; then
#                                 if [ $githubJobCount -eq 0 ]; then
#                                       echo "Building Prod-Github-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Github-Issue-Tracker/build
#                                       echo " "
#                                       githubJobCount=`expr $githubJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1` 
#                                 fi
#                         elif [[ $job == *"Issue-Tracker-Jira-Skill"* ]] || [[ $job == *"Issue-Tracker-Skill-Kit"* ]]; then
#                                 if [ $jiraJobCount -eq 0 ]; then
#                                       echo "Building Prod-Jira-Issue-Tracker job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Jira-Issue-Tracker/build
#                                       echo " "
#                                       jiraJobCount=`expr $jiraJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Notification-Email-Skill"* ]]; then
#                                 if [ $emailJobCount -eq 0 ]; then
#                                       echo "Building Prod-Email-Notification job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Email-Notification/build
#                                       echo " "
#                                       emailJobCount=`expr $emailJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Notification-Slack-Skill"* ]]; then 
#                                 if [ $slackJobCount -eq 0 ]; then
#                                       echo "Building Prod-Slack-Notification job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Slack-Notification/build
#                                       echo " "
#                                       slackJobCount=`expr $slackJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi
#                         elif [[ $job == *"Reports"* ]]; then 
#                                 if [ $reportsJobCount -eq 0 ]; then
#                                       echo "Building Prod-Reports job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-Reports/build
#                                       echo " "
#                                       reportsJobCount=`expr $reportsJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                         elif [[ $job == *"VC-Git-Skill"* ]] || [[ $job == *"VC-Skill-Kit"* ]] || [[ $job == *"Codegen"* ]]; then
#                                 if [ $vcgitJobCount -eq 0 ]; then
#                                       echo "Building Prod-VC-Git job"
#                                       curl -s -X POST -u $FX_USER:$FX_PWD $FX_HOST/job/Prod-VC-Git/build
#                                       echo " "
#                                       vcgitJobCount=`expr $vcgitJobCount + 1`
#                                       tJobCount=`expr $tJobCount + 1`
#                                 fi

#                         else
#                               echo " No changes are there to build jobs" > /dev/null

#                         fi

#     done

#     echo "Total no. of jobs triggered/build are: $tJobCount"

#     exit 0

