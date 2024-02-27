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
          checkScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 #sudo docker rm -f $FX_SCANNER_NAME
                 echo " "
                 echo "Docker Container/Scanner with '$FX_SCANNER_NAME' name already exists, so won't deploy it!!"
          else
                 echo "Deploying '$FX_SCANNER_NAME'  Scanner!!"
                 #sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                 sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                 sleep 10
                 sudo docker ps
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner Deployment is successfully completed!!"
          fi
elif [ "$option" = "2" ]; then
          checkScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo "Restarting  '$FX_SCANNER_NAME'  Scanner!!"
                 sudo docker restart $FX_SCANNER_NAME
                 sleep 5
                 sudo docker ps
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner is successfully restarted!!"
          else
                echo " "
                echo "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to restart. Please Deploy it!!"
                #sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                #sleep 10
                #sudo docker ps
          fi
elif [ "$option" = "3" ]; then
          checkScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo "Refreshing  '$FX_SCANNER_NAME'  Scanner!!"
                 sudo docker rm -f $FX_SCANNER_NAME
                 sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                 sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                 sleep 10
                 sudo docker ps
                 echo " "
                 echo "'$FX_SCANNER_NAME' Scanner is successfully refreshed!!"
          else
                echo " "
                echo "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to refresh. Please Deploy it!!"
                #sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                #sleep 10
                #sudo docker ps
          fi
else
     echo " "
     echo "Entered Option: $option"
     echo "You Didn't specify correct option. Please rerun the script again and specify right option based on your requirement!!"
fi

exit 0

if [ "$FX_DELAY" != "" ] && [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
          echo "Deploying Rate-Limiting Scanner with Delay: "$FX_DELAY", concurrentCoumsers: "$FX_CONCURRENT_CONSUMERS" and maxConcurrentConsumers: $FX_MAX_CONCURRENT_CONSUMERS"
          deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 sudo docker rm -f $FX_SCANNER_NAME
          fi
          sudo docker pull apisec/scanner:$FX_IMAGE_TAG
          sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
          sleep 10
          sudo docker ps
elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
          echo "Deploying Scanner with concurrentCoumsers: $FX_CONCURRENT_CONSUMERS and maxConcurrentConsumers: $FX_MAX_CONCURRENT_CONSUMERS"
          deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 sudo docker rm -f $FX_SCANNER_NAME
          fi
          sudo docker pull apisec/scanner:$FX_IMAGE_TAG
          sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS apisec/scanner:$FX_IMAGE_TAG
          sleep 10
          sudo docker ps
elif [ "$FX_DELAY" != "" ]; then
          echo "Deploying Scanner with Delay: $FX_DELAY"
          deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 sudo docker rm -f $FX_SCANNER_NAME
          fi
          sudo docker pull apisec/scanner:$FX_IMAGE_TAG
          sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
          sleep 10
          sudo docker ps
else          
          deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 sudo docker rm -f $FX_SCANNER_NAME
          fi
          sudo docker pull apisec/scanner:$FX_IMAGE_TAG
          sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
          sleep 10
          sudo docker ps
fi
