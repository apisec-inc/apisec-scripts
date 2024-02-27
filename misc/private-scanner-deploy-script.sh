#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "host:,scannerName:,portNumber:,fx-iam:,fx-key:,imageTag:,fx-ssl:,platform:,concurrentConsumers:,maxConcurrentConsumers:,delay:,replicas:,k8sDeployMode:" -- -- "$@")

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
                    --replicas) FX_REPLICAS="$2"; shift;;
                    --k8sDeployMode) FX_K8S_DEPLAY_MODE="$2"; shift;;
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

if [ "$FX_REPLICAS" = "" ];
then
FX_REPLICAS="1"
fi

if [ "$FX_PLATFORM" = "Docker" ];
then

      if ! sudo docker info > /dev/null 2>&1; then
              echo "This script uses docker, and it isn't running - please start docker and try again!"
              exit 1
      else
              echo "Docker is running"

              if ! nc -z -w10 cloud.apisec.ai 5671  > /dev/null 2>&1; then
                   echo "APIsec Rabbitmq SSL Port 5671 is  not reachable from this Location/Resource!!"
                   echo "Please Make Sure APIsec Rabbitmq SSL Port 5671 is  whitelisted in Your Firewall settings in the outbound Request!!"
                   exit 1
              else
                   echo "APIsec Rabbitmq SSL Port 5671 is reachable from this Location/Resource!!"
                   if [ "$FX_DELAY" != "" ] && [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                         echo "Delay, concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                         deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
                         if [ "$deleteScanner" != "" ]; then
                               sudo docker rm -f $FX_SCANNER_NAME
                         fi
                         sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                         sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
                         sleep 10
                         sudo docker ps
                   elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                         echo "Only concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                         deleteScanner=$(sudo docker ps -a | grep $FX_SCANNER_NAME)
                         if [ "$deleteScanner" != "" ]; then
                               sudo docker rm -f $FX_SCANNER_NAME
                         fi
                         sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                         sudo  docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS apisec/scanner:$FX_IMAGE_TAG
                         sleep 10
                         sudo docker ps
                   elif [ "$FX_DELAY" != "" ]; then
                         echo "Delay only parameter is passed"
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
              fi
      fi

elif [ "$FX_PLATFORM" = "Docker-Swarm" ];
then

      if ! sudo docker info > /dev/null 2>&1; then
              echo "This script uses docker, and it isn't running - please start docker and try again!"
              exit 1
      else
              echo "Docker is running"

              if ! nc -z -w10 cloud.apisec.ai 5671  > /dev/null 2>&1; then
                    echo "APIsec Rabbitmq SSL Port 5671 is  not reachable from this Location/Resource!!"
                    echo "Please Make Sure APIsec Rabbitmq SSL Port 5671 is  whitelisted in Your Firewall settings in the outbound Request!!"
                    exit 1
              else
                    echo "APIsec Rabbitmq SSL Port 5671 is reachable from this Location/Resource!!"

                   if [ "$( sudo docker info --format '{{.Swarm.LocalNodeState}}')" = "active" ]; then
                          echo "node is running in docker swarm mode!!"
                          if [ "$FX_DELAY" != "" ] && [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Delay, concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(sudo docker service ls | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        sudo docker service rm  $FX_SCANNER_NAME
                                  fi
                                  sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                                  sudo  docker service create --name $FX_SCANNER_NAME --replicas $FX_REPLICAS --env FX_HOST=$FX_HOST --env FX_IAM=$FX_IAM --env FX_KEY=$FX_KEY --env FX_PORT=$FX_PORT --env FX_SSL=$FX_SSL --env concurrentConsumers=$FX_CONCURRENT_CONSUMERS --env maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS --env delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
                                  sleep 10
                                  sudo docker ps
                          elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Only concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(sudo docker service ls | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        sudo docker service rm  $FX_SCANNER_NAME
                                  fi
                                  sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                                  sudo  docker service create --name $FX_SCANNER_NAME --replicas $FX_REPLICAS --env FX_HOST=$FX_HOST --env FX_IAM=$FX_IAM --env FX_KEY=$FX_KEY --env FX_PORT=$FX_PORT --env FX_SSL=$FX_SSL --env concurrentConsumers=$FX_CONCURRENT_CONSUMERS --env maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS apisec/scanner:$FX_IMAGE_TAG
                                  sleep 10
                                  sudo docker ps
                          elif [ "$FX_DELAY" != "" ]; then
                                  echo "Delay only parameter is passed"
                                  deleteScanner=$(sudo docker service ls | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        sudo docker service rm  $FX_SCANNER_NAME
                                  fi
                                  sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                                  sudo  docker service create --name $FX_SCANNER_NAME --replicas $FX_REPLICAS --env FX_HOST=$FX_HOST --env FX_IAM=$FX_IAM --env FX_KEY=$FX_KEY --env FX_PORT=$FX_PORT --env FX_SSL=$FX_SSL --env concurrentConsumers=$FX_CONCURRENT_CONSUMERS --env maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS --env delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
                                  sleep 10
                                  sudo docker ps
                          else
                                  echo "Default usecae"
                                  deleteScanner=$(sudo docker service ls | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        sudo docker service rm  $FX_SCANNER_NAME
                                        sleep 5
                                  fi
                                  sudo docker pull apisec/scanner:$FX_IMAGE_TAG
                                  sudo  docker service create  --name $FX_SCANNER_NAME --replicas $FX_REPLICAS --env FX_HOST=$FX_HOST --env FX_IAM=$FX_IAM --env FX_KEY=$FX_KEY --env FX_PORT=$FX_PORT --env FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                                  sleep 10
                                  sudo docker ps
                          fi
                   else
                          echo "node is not running in docker swarm mode!!"
                          exit 1
                   fi
              fi
      fi
elif [ "$FX_PLATFORM" = "Kubernetes" ];
then
      if !  kubectl cluster-info > /dev/null 2>&1; then
            echo "This script uses k8s cluster, and it isn't running - please start kubernetes cluster and try again!"
            exit 1
      else
            echo "Kubernetes Cluster is running"

            if ! nc -z -w10 cloud.apisec.ai 5671  > /dev/null 2>&1; then
                  echo "APIsec Rabbitmq SSL Port 5671 is  not reachable from this Location/Resource!!"
                  echo "Please Make Sure APIsec Rabbitmq SSL Port 5671 is  whitelisted in Your Firewall settings in the outbound Request!!"
                  exit 1
            else
                  echo "APIsec Rabbitmq SSL Port 5671 is reachable from this Location/Resource!!"
                  if    [ "$FX_K8S_DEPLAY_MODE" = "" ]; then

                          if [ "$FX_DELAY" != "" ] && [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Delay, concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(kubectl get po  | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete po  $FX_SCANNER_NAME
                                  fi
                                  kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS" --env="delay=$FX_DELAY" --image="apisec/scanner:$FX_IMAGE_TAG"
                                  sleep 10
                                  kubectl get po
                          elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Only concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete po  $FX_SCANNER_NAME
                                  fi
                                  kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS" --image="apisec/scanner:$FX_IMAGE_TAG"
                                  sleep 10
                                  kubectl get po
                          elif [ "$FX_DELAY" != "" ]; then
                                  echo "Delay only parameter is passed"
                                  deleteScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete po  $FX_SCANNER_NAME
                                  fi
                                  kubectl run $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="delay=$FX_DELAY" --image="apisec/scanner:$FX_IMAGE_TAG"
                                  sleep 10
                                  kubectl get po
                          else
                                  echo "Default usecae"
                                  deleteScanner=$(kubectl get po | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete po  $FX_SCANNER_NAME
                                        sleep 5
                                  fi
                                  kubectl run  $FX_SCANNER_NAME  --env FX_HOST=$FX_HOST --env FX_IAM=$FX_IAM --env FX_KEY=$FX_KEY --env FX_PORT=$FX_PORT --env FX_SSL=$FX_SSL  --image="apisec/scanner:$FX_IMAGE_TAG"
                                  sleep 10
                                  kubectl get po
                          fi
                  elif  [ "$FX_K8S_DEPLAY_MODE" = "Deployment" ]; then
                          echo "K8S Deployment Mode Selected!!"

                          if [ "$FX_DELAY" != "" ] && [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Delay, concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(kubectl get deployment  | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete deployment  $FX_SCANNER_NAME
                                  fi
                                  kubectl create  deployment $FX_SCANNER_NAME --replicas=$FX_REPLICAS   --image="apisec/scanner:$FX_IMAGE_TAG"
                                  kubectl set env deployment $FX_SCANNER_NAME  --env="FX_HOST=$FX_HOST" --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS" --env="delay=$FX_DELAY" 
                                  sleep 10
                                  kubectl get po
                          elif [ "$FX_CONCURRENT_CONSUMERS" != "" ] && [ "$FX_MAX_CONCURRENT_CONSUMERS" != "" ]; then
                                  echo "Only concurrentCoumsers and maxConcurrentConsumers  parameters are passed!!"
                                  deleteScanner=$(kubectl get deployment | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete deployment  $FX_SCANNER_NAME
                                  fi
                                  kubectl create  deployment $FX_SCANNER_NAME  --replicas=$FX_REPLICAS   --image="apisec/scanner:$FX_IMAGE_TAG"
                                  kubectl set env deployment $FX_SCANNER_NAME  --env="FX_HOST=$FX_HOST"  --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="concurrentConsumers=$FX_CONCURRENT_CONSUMERS" --env="maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS"
                                  sleep 10
                                  kubectl get po
                          elif [ "$FX_DELAY" != "" ]; then
                                  echo "Delay only parameter is passed"
                                  deleteScanner=$(kubectl get deployment | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete deployment  $FX_SCANNER_NAME
                                  fi
                                  kubectl create  deployment $FX_SCANNER_NAME  --replicas=$FX_REPLICAS   --image="apisec/scanner:$FX_IMAGE_TAG"
                                  kubectl set env deployment $FX_SCANNER_NAME  --env="FX_HOST=$FX_HOST"  --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL" --env="delay=$FX_DELAY"
                                  sleep 10
                                  kubectl get po
                          else
                                  echo "Default usecae"
                                  deleteScanner=$(kubectl get deployment | grep $FX_SCANNER_NAME)
                                  if [ "$deleteScanner" != "" ]; then
                                        kubectl delete deployment  $FX_SCANNER_NAME
                                        sleep 5
                                  fi
                                  kubectl create  deployment  $FX_SCANNER_NAME --replicas=$FX_REPLICAS   --image="apisec/scanner:$FX_IMAGE_TAG"
                                  kubectl set env deployment  $FX_SCANNER_NAME --env="FX_HOST=$FX_HOST"  --env="FX_IAM=$FX_IAM" --env="FX_KEY=$FX_KEY" --env="FX_PORT=$FX_PORT" --env="FX_SSL=$FX_SSL"
                                  sleep 10
                                  kubectl get po
                          fi
                  fi

            fi
      fi

else
      echo "No Platform is specified where to deploy the scanner."
      echo "Please specify a platform to deploy the scanner like docker, docker-swarm or kubernetes to proceed further."
      exit 1
fi

