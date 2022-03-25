
#!/bin/bash
# Begin

# How to run this script.

# Syntax:        bash apisec-project-creation-script.sh  --username "<username>"      --password "<password>"  --hostname "<Hostname or IP>" --projectname "devops"  --openapispecurl "<Open APi Spec URL>"                            --NoProjects "<No of projects to create>"
# Example usage: bash apisec-project-creation-script.sh  --username "admin@apisec.ai" --password "apisec@5421" --hostname "20.99.193.218"    --projectname "devops"  --openapispecurl "http://application.apisec.ai:8080/v2/api-docs"  --NoProjects "10"


TEMP=$(getopt -n "$0" -a -l "username:,password:,hostname:,projectname:,openapispecurl:,NoProjects:" -- --  "$@")
echo $TEMP

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --username) FX_USER="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --hostname) FX_HOSTNAME="$2"; shift;;
                    --projectname) FX_PROJECT_NAME="$2"; shift;;
                    --openapispecurl) FX_OpenAPISpecUrl="$2"; shift;;
                    --NoProjects) NoProjectsToCreate="$2"; shift;;                    
                    --) shift;;
             esac
             shift;
    done

echo " "
token=$(curl -k -s -H "Content-Type: application/json" -X POST -d '{"username": "'${FX_USER}'", "password": "'${FX_PWD}'"}' "https://${FX_HOSTNAME}/login" | jq -r .token)
echo "generated token is:" $token
echo " "


count=0
for i in `seq $NoProjectsToCreate`
do
  count=`expr $count + 1`  
  RANDOM=$$
  FX_PROJECTNAME="${FX_PROJECT_NAME}${RANDOM}${count}"
  echo "ProjectName: $FX_PROJECTNAME Iteration No: $count"
  curl  -k -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://${FX_HOSTNAME}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECTNAME}'","openAPISpec":"'${FX_OpenAPISpecUrl}'","planType":"ENTERPRISE","personalizedCoverage":{"auths":[]}}'
  echo " "
  echo " "
  echo "Will wait for 2 mintues before making another post request for new project registration."
  echo " "
  
  sleep 120
done

echo "Successfully created $NoProjectsToCreate projects in $FX_HOSTNAME environment!!!"
