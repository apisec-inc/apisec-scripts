#!/bin/bash
# Begin

# Syntax: bash gcp-report-storage.sh  --username "" --password "" --hostname "" --projectname ""

TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,reportaccesscredentials:,bucketName:,name:,accountType:,tags:" -- --  "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --hostname) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --reportaccesscredentials) accessKey="$2"; shift;;
                    --bucketName) BUCKET_NAME="$2"; shift;;
                    --name) NAME="$2"; shift;;
                    --accountType) GOOGLE_CLOUD_STORAGE="$2"; shift;;
                    --tags) FX_TAGS="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

if [ "$FX_HOST" = "" ];
then
FX_HOST="https://apitest.apisec.ai"
fi

fileExt=$(echo $accessKey)

if [[ "$fileExt" == *"json"* ]]; then
      echo " "
      accessKey=$(cat "$accessKey" )
      accessKey1=$(echo $accessKey | jq -R )
fi

echo $accessKey1


echo "Now Generating Token"

token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' "https://${FX_HOST}/login" | jq -r .token)

echo "generated token is:" $token
echo ' '          	
 
curl -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://apitest.apisec.ai/api/v1/accounts" --header "Authorization: Bearer "$token"" -d  '{"accessKey":'"${accessKey1}"',"bucketName":"'${BUCKET_NAME}'","name":"'${NAME}'","accountType":"'${GOOGLE_CLOUD_STORAGE}'","autoOnboard": false,"isDefaultStore":false,"isdefault":false,"org":{}}' 

echo ' '
echo "Successfully Create Report Access Credentials."
