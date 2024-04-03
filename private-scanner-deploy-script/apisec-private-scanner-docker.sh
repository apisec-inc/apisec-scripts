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

function scannerDeployment() {
FX_HOST=$1
FX_PORT=$2
#echo $FX_HOST
#echo $FX_PORT
echo " "
echo "Press '1' to Deploy  APIsec Scanner!!"
echo "Press '2' to Restart APIsec Scanner!!"
echo "Press '3' to Refresh APIsec Scanner!!"

read -p "Enter Your Option: " option

if [ "$option" = "1" ]; then
          checkScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 #sudo docker rm -f $FX_SCANNER_NAME
                 echo " "
                 echo "Docker Container/Scanner with '$FX_SCANNER_NAME' name already exists!!"
                 exit 1
          else
                 echo "Deploying '$FX_SCANNER_NAME'  Scanner!!"
                 #sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                 sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG 
                 sleep 10
                 sudo docker ps -a | grep $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 sudo docker logs $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 echo "'$FX_SCANNER_NAME' Scanner Deployment is successfully completed!!"
          fi
elif [ "$option" = "2" ]; then
          checkScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$checkScanner" != "" ]; then
                 echo "Restarting  '$FX_SCANNER_NAME'  Scanner!!"
                 sudo docker restart $FX_SCANNER_NAME
                 sleep 5
                 sudo docker ps -a | grep $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 sudo docker logs $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 echo "'$FX_SCANNER_NAME' Scanner is successfully restarted!!"
          else
                echo " "
                echo "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to restart. Please Deploy it!!"
                exit 1
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
                 sudo docker ps -a | grep $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 sudo docker logs $FX_SCANNER_NAME
                 echo " "
                 sleep 5
                 echo "'$FX_SCANNER_NAME' Scanner is successfully refreshed!!"
          else
                echo " "
                echo "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to refresh. Please Deploy it!!"
                exit 1
                #sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                #sleep 10
                #sudo docker ps
          fi
else
     echo " "
     echo "Entered Option: $option"
     echo "You Didn't specify correct option. Please rerun the script again and specify right option based on your requirement!!"
     exit 1
fi
}

echo "Checing APIsec Scanner Port No. '5671' Connectivity on the domain-name 'cloud.apisec.ai' from this Location/Resource!!"
if ! nc -z -w30 cloud.apisec.ai 5671  > /dev/null 2>&1; then
       echo " "
       echo "APIsec Scanner Port '5671' for domain-name 'cloud.apisec.ai' is  not reachable from this Location/Resource!!"
       echo " "
       echo "Checking connectvity on Scanner Port No. '443' for the 'APIsec' domain-name 'scanner.apisec.ai' from this location/resource!!"
       echo " "
       if ! nc -z -w30 scanner.apisec.ai 443  > /dev/null 2>&1; then
              echo "APIsec domain-name 'scanner.apisec.ai' on the Scanner Port no. '443' is also not reachable from this Location/Resource!!"
              echo " "
              echo "Please Make Sure Either of the below two APIsec domain names are added in the acceptList of your firewall settings to proceed/begin with scanner deployment!!"
              echo " "
              echo "Open 5671 Port No. for the domain-name 'cloud.apisec.ai'   in the outbound request!!"
              echo "OR"
              echo "Open 443  Port No. for the domain-name 'scanner.apisec.ai' in the outbound request!!"
              exit 1
       else
              echo "APIsec Scanner Port '443' for domain-name 'scanner.apisec.ai' is reachable from this Location/Resource!!"
              echo "We can proceed with '$FX_SCANNER_NAME' scanner deployment!!"
              echo " "
              FX_HOST="scanner.apisec.ai"
              FX_PORT="443"
              scannerDeployment $FX_HOST $FX_PORT
              #echo "Script Execution is Done!!"
       fi

else
      echo "APIsec Scanner Port '5671' for domain-name 'cloud.apisec.ai' is reachable from this Location/Resource!!"
      echo "We can proceed with the '$FX_SCANNER_NAME' scanner deployment!!"
      echo " "
      scannerDeployment $FX_HOST $FX_PORT
      #echo "Script Execution is Done!!"
fi
