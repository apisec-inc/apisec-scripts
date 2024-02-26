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
          echo "Default usecae"
          deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 sudo docker rm -f $FX_SCANNER_NAME
          fi
          sudo docker pull apisec/scanner:$FX_IMAGE_TAG
          sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
          sleep 10
          sudo docker ps
fi
