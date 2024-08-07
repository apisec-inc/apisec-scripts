TEMP=$(getopt -n "$0" -a -l "username:,password:,host:,project:,vaultAccountName:,accessKey:,secretKey:,bucketName:,bucketRegion:,isDefaultStore:,inActive" -- --  "$@")
#echo $TEMP

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --host) FX_HOST="$2"; shift;;
                    --project) FX_PROJECT_NAME="$2"; shift;;
                    --vaultAccountName) FX_VAULT_ACCOUNT="$2"; shift;;
                    --accessKey) FX_ACCESS_KEY="$2"; shift;;
                    --secretKey) FX_SECRET_KEY="$2"; shift;;
                    --bucketName) FX_BUCKET_NAME="$2"; shift;;
                    --bucketRegion) FX_BUCKET_REGION="$2"; shift;;                                                            
                    --isDefaultStore) IS_DEFAULT_STORE="$2"; shift;;
                    --inActive) IN_ACTIVE="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done

if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai"
fi    

if [ "$FX_PROJECT_NAME" != "" ]; then
      PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/-/ /g' | sed 's/@/ /g' | sed 's/#/ /g' |  sed 's/&/ /g' | sed 's/*/ /g' |  sed 's/(/ /g' | sed 's/)/ /g' | sed 's/=/ /g' | sed 's/+/ /g' | sed 's/~/ /g' | sed 's/\// /g' | sed 's/\\/ /g' | sed 's/\^/ /g' | sed 's/\;/ /g' | sed 's/\:/ /g' | sed 's/\[/ /g' | sed 's/\]/ /g' | sed 's/\./ /g' | sed 's/\,/ /g')
      FX_PROJECT_NAME=$( echo "$FX_PROJECT_NAME" | sed 's/ /%20/g' |  sed 's/-/%20/g' | sed 's/@/%20/g' | sed 's/#/%20/g' |  sed 's/&/%20/g' | sed 's/*/%20/g' |  sed 's/(/%20/g' | sed 's/)/%20/g' | sed 's/=/%20/g' | sed 's/+/%20/g' | sed 's/~/%20/g' | sed 's/\//%20/g' | sed 's/\\/%20/g' | sed 's/\^/%20/g' | sed 's/\;/%20/g' | sed 's/\:/%20/g' | sed 's/\[/%20/g' | sed 's/\]/%20/g' | sed 's/\./%20/g' | sed 's/\,/%20/g')
fi

if [ "$IS_DEFAULT_STORE" = "true" ];
then
     IS_DEFAULT_STORE=true
else 
     IS_DEFAULT_STORE=false   
fi   

if [ "$IN_ACTIVE" = "true" ];
then
     IN_ACTIVE=true
else 
     IN_ACTIVE=false   
fi 

# For Project Name exist check
if   [ "$FX_PROJECT_NAME" == ""  ]; then
        PROJECT_NAME_FLAG=false
else 
        PROJECT_NAME_FLAG=true
fi


if [ "$FX_VAULT_ACCOUNT" = "" ]; then
           echo "Please Pass Vault Account Name to create/update and run the script again!!"  
           exit 1
fi

if [ "$FX_ACCESS_KEY" = "" ]; then
            
           echo "Please Pass Access_Key value to be used and run the script again!!"  
           exit 1
fi

if [ "$FX_SECRET_KEY" = "" ]; then
            
           echo "Please Pass Secret_Key value to be used  and run the script again!!"  
           exit 1
fi


if [ "$FX_BUCKET_NAME" = "" ]; then
            
           echo "Please Pass S3 Bucket value to be used and run the script again!!"  
           exit 1
fi

if [ "$FX_BUCKET_REGION" = "" ]; then
            
           echo "Please Pass S3 Bucket Region value to be used and run the script again!!"  
           exit 1
fi


if [ "$FX_VAULT_ACCOUNT" != "" ]; then
     FX_VAULT_ACCOUNT_NAME=$( echo "$FX_VAULT_ACCOUNT" | sed 's/ /%20/g' )
fi

tokenResp=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' ${FX_HOST}/login )
#tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | cut -d{ -f1 | cut -d} -f2 | cut -d'"' -f2)
tokenResp1=$(echo "$tokenResp" | jq -r . | cut -d: -f1 | tr -d '{' | tr -d '}' | tr -d '"') 
if [ $tokenResp1 == "token" ];then
      token=$(echo $tokenResp | jq -r '.token')
      echo " "
      echo "generated token is:" $token
      echo " "  
elif [ $tokenResp1 == "message" ];then  
       message=$(echo $tokenResp | jq -r '.message')
       echo "$message. Please provide correct User Credentials!!"
       echo " "
       exit 1
fi
echo " "
pages=3
page=0
count=0

while [ $page -le $pages ]
    do         
         vaultData=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $token"  -X GET "${FX_HOST}/api/v1/accounts/search?keyword=${FX_VAULT_ACCOUNT_NAME}&page=${page}&pageSize=100&sort=modifiedDate&sortType=DESC")
         readarray -t vData < <(echo "$vaultData" | jq -c '.data[]')         
         for vault in "${vData[@]}"
             do
                   accountName=$(echo "$vault" | jq -r '.name')
                   accountType=$(echo "$vault" | jq -r '.accountType')
                   if [ "$FX_VAULT_ACCOUNT" == "$accountName" ]; then                         
                         count=`expr $count + 1`
                         dto=$(echo "$vault")
                         vault_id=$(echo $vault | jq -r '.id')
                         echo " "
                         break;
                   fi
             done 
         page=`expr $page + 1`
    done
if   [ $count -eq 0 ]; then
       echo "Vault Account with the name '$FX_VAULT_ACCOUNT' doesn't exists, so creating it!!"                                                                                                                                          
       response=$(curl -s -H "Content-Type: application/json" -H "Authorization: Bearer $token"  -X POST  "${FX_HOST}/api/v1/accounts" -d '{"isDefaultStore": '${IS_DEFAULT_STORE}',"name":"'${FX_VAULT_ACCOUNT}'","accountType":"AWS_S3","region":"'${FX_BUCKET_REGION}'","accessKey":"'${FX_ACCESS_KEY}'","secretKey":"'${FX_SECRET_KEY}'","bucketName":"'${FX_BUCKET_NAME}'"}')                                
       data=$(jq -r '.data' <<< "$response")
       echo ' '
       vault_name=$(jq -r '.name' <<< "$data")
       vault_id=$(jq -r '.id' <<< "$data")
       vault_type=$(jq -r '.accountType' <<< "$data")
       vault_bucket_name=$(jq -r '.bucketName' <<< "$data")
       vault_bucket_region=$(jq -r '.region' <<< "$data")
       vault_isDefaultStore=$(jq -r '.isDefaultStore' <<< "$data")
       if [ -z "$vault_id" ] || [  "$vault_id" == null ]; then                   
                   message=$(jq -r '.message' <<< "$response") 
                   echo "Error Message: $message"
                   echo " "
                   exit 1
       else
                  echo "Successfully Created Vault!!"       
                  echo "VaultName: $vault_name"
                  echo "Vault_ID: $vault_id"
                  echo "Vault AccountType: $vault_type"
                  echo "Bucket Name: $vault_bucket_name"
                  echo "Bucket Region: $vault_bucket_region"
                  echo "IsStorageDefaultStoreActive: $vault_isDefaultStore"
                  echo " "
       fi
elif [ $count -eq 1 ]; then
       if [ "$accountType" == "AWS_S3" ]; then
             echo "Vault Account with the name '$FX_VAULT_ACCOUNT' alraedy exists, so updating it!!"            
             updatedDto=$(echo "$dto" | jq  -c --arg region "$FX_BUCKET_REGION" --arg accessKey "$FX_ACCESS_KEY" --arg secretKey "$FX_SECRET_KEY" --arg bucketName "$FX_BUCKET_NAME" --argjson isDefaultStore "$IS_DEFAULT_STORE" ' .region = $region | .accessKey = $accessKey | .secretKey = $secretKey | .bucketName = $bucketName | .isDefaultStore = $isDefaultStore')
             response=$(curl -s -H "Accept: application/json"  -H "Content-Type: application/json" -H "Authorization: Bearer $token"  -X PUT  "${FX_HOST}/api/v1/accounts/${vault_id}"  -d "$updatedDto")                           
             data=$(jq -r '.data' <<< "$response")
             echo ' '
             vault_name=$(jq -r '.name' <<< "$data")
             vault_id=$(jq -r '.id' <<< "$data")
             vault_type=$(jq -r '.accountType' <<< "$data")
             vault_bucket_name=$(jq -r '.bucketName' <<< "$data")
             vault_bucket_region=$(jq -r '.region' <<< "$data")
             vault_isDefaultStore=$(jq -r '.isDefaultStore' <<< "$data")
             if [ -z "$vault_id" ] || [  "$vault_id" == null ]; then                       
                       message=$(jq -r '.messages' <<< "$response") 
                       echo "Error Message: $message"
                       echo " "
                       exit 1
             else
                      echo "Successfully Updated Vault!!"               
                      echo "VaultName: $vault_name"
                      echo "Vault_ID: $vault_id"
                      echo "Vault AccountType: $vault_type"
                      echo "Bucket Name: $vault_bucket_name"
                      echo "Bucket Region: $vault_bucket_region"
                      echo "IsStorageDefaultStoreActive: $vault_isDefaultStore"
                      echo " "
             fi             

       else
             echo "Vault Account with the name '$FX_VAULT_ACCOUNT' alraedy exists, but it is of AccountType '$accountType' so  cannot update it!!"
             echo "Please pass Vault Name whose AccountType is 'AWS_S3'"
             exit 1
       fi
fi

# To check Project Name existence 
if [ "$PROJECT_NAME_FLAG" = true ]; then
      pdtoData=$(curl  -s --location --request GET  "${FX_HOST}/api/v1/projects/find-by-name/${FX_PROJECT_NAME}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"")
      errorsFlag=$(echo "$pdtoData" | jq -r '.errors')      
      if [ $errorsFlag = true ]; then           
           errMsg=$(echo "$pdtoData" | jq -r '.messages[].value' | tr -d '[' | tr -d ']')           
           echo $errMsg
           exit 1
      elif [ $errorsFlag = false ]; then            
            pdto=$(echo "$pdtoData" | jq -r '.data')
            PROJECT_ID=$(echo "$pdto" | jq -r '.id')
            getProjectName=$(echo "$pdtoData" | jq -r '.data.name')
            rCount=0
            reportStorageData=$(curl -s -H "Accept: application/json"  -H "Content-Type: application/json" -H "Authorization: Bearer $token" -X GET "${FX_HOST}/api/v1/accounts/account-type/REPORT_STORAGE")
            readarray -t rData < <(echo "$reportStorageData" | jq -c '.data[]')
            for rVault in "${rData[@]}"
                do
                     accountName=$(echo "$rVault" | jq -r '.name')        
                     if [ "$FX_VAULT_ACCOUNT" == "$accountName" ]; then
                           rDto=$(echo "$rVault")
                           rCount=`expr $rCount + 1`
                           break;
                     fi        
         
                done
            if [ $rCount -eq 0 ]; then
                  echo "$FX_VAULT_ACCOUNT vault as storage vault doesn't exists!!"
                  exit 1
            elif [ $rCount -eq 1 ]; then
                   projData=$(curl -s --location --request GET "${FX_HOST}/api/v1/report-setting/project/${PROJECT_ID}" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" | jq -r '.data')
                   updatedProjData=$(echo "$projData" | jq -c --argjson account "$rDto" --argjson inactive "$IN_ACTIVE" --arg projectId "$PROJECT_ID" '.account = $account | .inactive = $inactive | .projectId = $projectId')
                   reportsData=$(curl -s --location --request POST "${FX_HOST}/api/v1/report-setting" --header "Accept: application/json" --header "Content-Type: application/json" --header "Authorization: Bearer "$token"" -d "$updatedProjData")
                   updateProjectId=$(echo "$reportsData" | jq -r '.data.projectId')
                   updateProjectInActive=$(echo "$reportsData" | jq -r '.data.inactive')
                   updatedProjectVaultName=$(echo "$reportsData" | jq -r '.data.account.name')
                   updatedProjectVaultId=$(echo "$reportsData" | jq -r '.data.account.id')
                   updatedProjectVaultaccountType=$(echo "$reportsData" | jq -r '.data.account.accountType')
                   updatedProjectVaultBucketName=$(echo "$reportsData" | jq -r '.data.account.bucketName')
                   updatedProjectVaultBucketRegion=$(echo "$reportsData" | jq -r '.data.account.region')
                   echo "Successfully Updated '$getProjectName' project with '$FX_VAULT_ACCOUNT' as reportStorage account!!"
                   echo "ProjectName: $getProjectName"
                   echo "ProjectId: $updateProjectId"                   
                   echo "updatedReportsStorageDetails:"
                   echo "VaultName: $updatedProjectVaultName"
                   echo "Vault_ID: $updatedProjectVaultId"
                   echo "Vault AccountType: $updatedProjectVaultaccountType"
                   echo "Bucket Name: $updatedProjectVaultBucketName"
                   echo "Bucket Region: $updatedProjectVaultBucketRegion"
                   echo "IsProjectStorageAccountInActive: $updateProjectInActive"
                   echo " "
            fi       
      fi
fi



echo "Script Execution is done!!"
