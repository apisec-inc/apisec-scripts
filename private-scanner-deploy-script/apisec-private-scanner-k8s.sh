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
          deleteScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 kubectl delete po $FX_SCANNER_NAME
          fi          
          kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS" --env="delay=$FX_DELAY" --image="apisec/scanner:$FX_IMAGE_TAG"
          sleep 10
          kubectl get po
elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
          echo "Deploying Scanner with concurrentCoumsers: $FX_CONCURRENT_CONSUMERS and maxConcurrentConsumers: $FX_MAX_CONCURRENT_CONSUMERS"
          deleteScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 kubectl delete po $FX_SCANNER_NAME
          fi          
          kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS" --image="apisec/scanner:$FX_IMAGE_TAG"
          sleep 10
          kubectl get po
elif [ "$FX_DELAY" != "" ]; then
          echo "Deploying Scanner with Delay: $FX_DELAY"
          deleteScanner=$(kubectl get po| grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 kubectl delete po $FX_SCANNER_NAME
          fi          
          kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="delay=$FX_DELAY" --image="apisec/scanner:$FX_IMAGE_TAG"
          sleep 10
          kubectl get po
else          
          echo "Deploying Scanner with Delay: $FX_DELAY"
          deleteScanner=$(kubectl get po| grep $FX_SCANNER_NAME)
          if [ "$deleteScanner" != "" ]; then
                 kubectl delete po $FX_SCANNER_NAME
          fi          
          kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --image="apisec/scanner:$FX_IMAGE_TAG"
          sleep 10
          kubectl get po
fi
