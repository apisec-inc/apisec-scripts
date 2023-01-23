#!/bin/bash
# Begin


# Script Purpose: This script will capture log messages based on user defined keywords if those log message present in the pods.
#
#
# How to run the this script.
# Syntax:        bash apisec-k8s-logs-capture.sh  --logMessage   "<log message to be captured>"

# Example usage: bash apisec-k8s-logs-capture.sh  --logMessage   "exception"

# Note!!! 1. This script needs to be run against a running k8s cluster from bash shell prompt.

#         2. This script will create a directory named "log-messages" in the present working directory and store all the captured log messages
#            files of the respective pods in that directory.

#         3. Please make sure linux user thorugh whom this script will be run have appropriate permissions for a directory from present working directory.

#         4. If no --logMessage parameter is passed during the script execution time, then 'exception' key-word log messages will be captured by default.
#            Eg: bash apisec-logs-capture.sh

TEMP=$(getopt -n "$0" -a -l "logMessage:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --logMessage) LOG_MESSAGE="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

if [ "$LOG_MESSAGE" = "" ];
then
LOG_MESSAGE="exception"
fi

echo "Checking $LOG_MESSAGE log messages!!"
sleep 5

if [ -d "log-messages" ]; then
         echo "Directory 'log-messages' exits!!"
         ls
         echo " "
else
         ls
         echo "Directory 'log-messages' doesn't  exists, will create it!!"
         mkdir log-messages
         ls
fi

sleep 10


podIds=$(kubectl get po | awk '{print $1}' | sed -n '1d;p')
echo " "
echo "$podIds"
echo " "

for id in ${podIds}

    do
        dat=$(date "+%F-%H%M%S")
        logs=$(kubectl logs $id | grep $LOG_MESSAGE)
        if  [ "$logs" = "" ]; then
             echo "No $LOG_MESSAGE message in $id pod!"
             echo " "
        else

             echo "$logs" >> log-messages/$id-$LOG_MESSAGE-logs-$dat.txt
             ls log-messages
             echo " "
        fi
    done
echo " "
ls log-messages

echo " "
echo "Script Execution is completed!!"
