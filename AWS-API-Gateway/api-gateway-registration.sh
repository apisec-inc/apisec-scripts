#!/bin/bash
# Begin

TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,accesskey:,secretkey:,name:,sessiontoken:,accountType:,region:,tags:" -- --  "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --accesskey) ACCESS_KEY="$2"; shift;;
                    --secretkey) SECRET_KEY="$2"; shift;;
                    --name) NAME="$2"; shift;;
                    --sessiontoken) SESSION_TOKEN="$2"; shift;;                    
                    --accountType) ACCOUNT_TYPE="$2"; shift;;
                    --region) REGION="$2"; shift;;
                    --tags) FX_TAGS="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi


echo "Now Generating Token"

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' "${FX_HOST}/login" | jq -r .token)

echo "generated token is:" $token
echo ' '          	

aws configure set aws_access_key_id "${ACCESS_KEY}"  && aws configure set aws_secret_access_key "${SECRET_KEY}"  && aws configure set region "${REGION}" && aws configure set output "json"

sessiontoken=$(aws sts get-session-token --duration-seconds 129600 | jq -r '.Credentials.SessionToken')

echo "generated session-token is:" $sessiontoken

Data=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/accounts" --header "Authorization: Bearer "$token"" -d  '{"org":{},"isDefaultStore":false,"isdefault":false,"autoOnboard":false,"prop1":"BASIC","prop3":"PRODUCT","name":"'${NAME}'","accountType":"'${ACCOUNT_TYPE}'","region":"'${REGION}'","accessKey":"'${ACCESS_KEY}'","secretKey":"'${SECRET_KEY}'","sessiontoken":"'${sessiontoken}'"}' | jq -r '.data')

APIGateWayId=$( jq -r '.id' <<< "$Data")
APIGateWayName=$( jq -r '.name' <<< "$Data")
APIGateWayRegion=$( jq -r '.region' <<< "$Data")
APIGateWayAccountType=$( jq -r '.accountType' <<< "$Data")

echo "APIGateWayName: $APIGateWayName"
echo "APIGateWayId: $APIGateWayId"
echo "APIGateWayAccountType: $APIGateWayAccountType"
echo "APIGateWayRegion: $APIGateWayRegion"
echo " "

echo "Successfully Register the AWS API Gateway."
