
#!/bin/bash
# Begin

# How to run this script.

# Syntax:        bash proj-crea-script.sh  --username "<username>"      --password "<password>"  --hostname "<Hostname or IP>" --projectname "devops"  --openapispecurl "<Open APi Spec URL>"                            --NoProjects "<No of projects to create>"
# Example usage: bash proj-crea-script.sh  --username "admin@apisec.ai" --password "apisec@5421" --hostname "20.99.193.218"    --projectname "devops"  --openapispecurl "http://netbanking.apisec.ai:8080/v2/api-docs"   --NoProjects "10"


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
#for ((i=0; i<NoProjectsToCreate; i++)); do
do    
  RANDOM=$$
  FX_PROJECTNAME="${FX_PROJECT_NAME}${RANDOM}${count}"
  echo "ProjectName: $FX_PROJECTNAME Iteration No: $count"
  data=$(curl  -k -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://${FX_HOSTNAME}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECTNAME}'","openAPISpec":"'${FX_OpenAPISpecUrl}'","planType":"ENTERPRISE","isFileLoad": false,"personalizedCoverage":{"auths":[]}}')
  #data=$(curl -k -s  -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${FX_HOST}/api/v1/projects" --header "Authorization: Bearer "$token"" -d  '{"name":"'${FX_PROJECT_NAME}'","openAPISpec":"'${FX_OpenAPISpecUrl}'","planType":"ENTERPRISE","isFileLoad": false,"personalizedCoverage":{"auths":[]}}' | jq -r '.data')
  echo " "  
  project_name=$(echo "$data" | jq -r '.data.name')
  project_id=$(echo "$data" | jq -r '.data.id')

  if [ -z "$project_id" ] || [  "$project_id" == null ]; then
        echo "Project Id is $project_id/empty" > /dev/null
  else
      
        echo "Successfully created the project."
        echo "ProjectName: $project_name"
        echo "ProjectId: $project_id"
        echo " "
        echo "Will wait for 30 seconds before making another post request for new project registration."
        echo " "
        count=`expr $count + 1`
        sleep 30        
  fi
done
if [ $count -gt 0 ]; then
     echo "Successfully created $NoProjectsToCreate projects in $FX_HOSTNAME environment!!!"
fi
