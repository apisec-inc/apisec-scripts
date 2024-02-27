#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "host:,scannerName:,portNumber:,fx-iam:,fx-key:,imageTag:,fx-ssl:,platform:,concurrentConsumers:,maxConcurrentConsumers:,delay:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --host) FX_HOST="$2"; shift;;
                    --scannerName) FX_SCANNER_NAME="$2"; shift;;
                    --portNumber) FX_PORT="$2"; shift;;
                    --fx-iam) FX_IAM="$2"; shift;;
                    --fx-key) FX_KEY="$2"; shift;;
                    --imageTag) FX_IMAGE_TAG="$2"; shift;;
                    --fx-ssl) FX_SSL="$2"; shift;;
                    --platform) FX_PLATFORM="$2"; shift;;
                    --concurrentConsumers) FX_CONCURRENT_CONSUMERS="$2"; shift;;
                    --maxConcurrentConsumers) FX_MAX_CONCURRENT_CONSUMERS="$2"; shift;;
                    --delay) FX_DELAY="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

if [ "$FX_HOST" = "" ];
then
FX_HOST="cloud.apisec.ai"
fi

if [ "$FX_PORT" = "" ];
then
FX_PORT="5671"
fi

if [ "$FX_SSL" = "" ];
then
FX_SSL="true"
fi

if [ "$FX_IMAGE_TAG" = "" ];
then
FX_IMAGE_TAG="latest"
fi

echo " "
read -p "Please Enter '1' to Deploy a scanner OR Enter '2' to Restart the scanner OR  Enter '3' to Refresh the scanner: " option

if [ "$option" = "1" ]; then
          checkScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo " "
                 echo "Kubernetes Pod/Scanner with '$FX_SCANNER_NAME' name already exists, so won't deploy it!!"
          else
                 echo "Deploying '$FX_SCANNER_NAME'  Scanner!!"
                 kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --image="apisec/scanner:$FX_IMAGE_TAG" --image-pull-policy=IfNotPresent
                 sleep 10
                 kubectl get po
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner Deployment is successfully completed!!"
          fi
elif [ "$option" = "2" ]; then
          checkScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo "Restarting  '$FX_SCANNER_NAME'  Scanner!!"
                 kubectl delete po $FX_SCANNER_NAME
                 kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --image="apisec/scanner:$FX_IMAGE_TAG" --image-pull-policy=IfNotPresent
                 sleep 5
                 kubectl get po
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner is successfully restarted!!"
          else
                echo " "
                echo "No Kubernetes Pod/Scanner with '$FX_SCANNER_NAME' name exists to restart. Please Deploy it!!"
          fi
elif [ "$option" = "3" ]; then
          checkScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo "Refreshing  '$FX_SCANNER_NAME'  Scanner!!"
                 kubectl delete po $FX_SCANNER_NAME
                 kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --image="apisec/scanner:$FX_IMAGE_TAG" --image-pull-policy=Always
                 sleep 10
                 kubectl get po 
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner is successfully refreshed!!"
          else
                echo " "
                echo "No Kubernetes Pod/Scanner with '$FX_SCANNER_NAME' name exists to refresh. Please Deploy it!!"
          fi
else
     echo " "
     echo "Entered Option: $option"
     echo "You Didn't specify correct option. Please rerun the script again and specify right option based on your requirement!!"
fi

