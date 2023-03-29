#!/bin/bash
# Begin
TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,tenantName:,profile:,scanner:,environment:,emailReport:,reportType:,tags:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --environment) FX_ENV="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --tenantName) FX_TENANT="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done


if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai/rabbit"
fi

data=$(curl -s --request GET --user $FX_USER:$FX_PWD --url $FX_HOST/api/queues | jq -r '.[]')
ilinecount=0 
fxServiceFailCount=0    

queue_names=$(jq -r '.name' <<< "$data")
queue_consumers=$(jq -r '.consumers' <<< "$data")
queue_messages=$(jq -r '.messages' <<< "$data")
tenant=$(echo $FX_TENANT | tr ' ' '-')
queues=$(paste -d':' <(printf '%s\n' "${queue_names}") <(printf '%s\n' "${queue_consumers}") <(printf '%s\n' "${queue_messages}"))

queues=$( echo "$queues" | sed 's/ /%20/g' )

for scan in ${queues}

do
          check=$(echo "$scan" | cut -c1-6)
          if [ "$check" == "spring" ]; then
                echo "" > /dev/null
          else
               check=$(echo "$scan" | cut -c1-2)
               if [ "$check" == "fx" ]; then
                     qName=$(echo "$scan" | cut -d: -f1)
                     qCount=$(echo "$scan" | cut -d: -f2)
                     qMessages=$(echo "$scan" | cut -d: -f3)
                     if [ "$qName" == "fx-baas" ] || [ "$qName" == "fx-caas-azure" ] || [ "$qName" == "fx-caas-aws-ec2" ] || [ "$qName" == "fx-caas-do" ] || [ "$qName" == "fx-caas-ds" ] || [ "$qName" == "fx-caas-gcp" ] || [ "$qName" == "fx-caas-ibm" ] || [ "$qName" == "fx-caas-k8" ] || [ "$qName" == "fx-caas-oracle" ] || [ "$qName" == "fx-caas-os" ] || [ "$qName" == "fx-caas-rackspace" ] || [ "$qName" == "fx-caas-vsphere%20%20%20%20%20%20%20%20" ] || [ "$qName" == "fx-default-region" ] || [ "$qName" == "fx-mlas" ]  || [ "$qName" == "fx-notification-ms-teams" ]; then

                          echo "$qName queue always/bydefault have zero consumers" > /dev/null
                          #echo "$qName queue always/bydefault have zero consumers, so we will skip it." 
                     else
                           if [ $qCount -eq 0 ]; then
                                 if [ $ilinecount -eq 0 ]; then
                                      dat=$(date -u)
#                                      echo "$dat" >> $FX_ENV-fx-Down-Queues.txt
                                      echo "Following APIsec $FX_ENV Environment Services are down or not working properly as there queues have zero consumers count, Devops team please take appropriate action!!!" > $FX_ENV-fx-Down-Queues-Alert.txt
                                      echo "$dat" >> $FX_ENV-fx-Down-Queues-Alert.txt
                                      echo " " >> $FX_ENV-fx-Down-Queues-Alert.txt
                                      ilinecount=`expr $ilinecount + 1`
                                 fi
                                 #echo "$scan" >> $FX_ENV-fx-Down-Queues.txt
                                 echo "Service-Queue-Name: $qName" >> $FX_ENV-fx-Down-Queues-Alert.txt
                                 echo "Service-Queue-Count: $qCount" >> $FX_ENV-fx-Down-Queues-Alert.txt
                                 echo "Total-Messages-In-Queue: $qMessages" >> $FX_ENV-fx-Down-Queues-Alert.txt
                                 echo " " >> $FX_ENV-fx-Down-Queues-Alert.txt
                                 fxServiceFailCount=`expr $fxServiceFailCount + 1`
                           fi
                     fi
               fi      
          fi
done

if [ $fxServiceFailCount -gt 0 ]; then
      echo " " >> $FX_ENV-fx-Down-Queues-Alert.txt
      echo "Total no. of APIsec $FX_ENV Environment Services Down/Not-Working  are: $fxServiceFailCount" >> $FX_ENV-fx-Down-Queues-Alert.txt
fi

if [ -s $FX_ENV-fx-Down-Queues-Alert.txt ]; then
         echo "file $FX_ENV-fx-Down-Queues-Alert.txt exits"
         cat $FX_ENV-fx-Down-Queues-Alert.txt
         echo " "
         echo "Breaking script execution as the file with the name $FX_ENV-fx-Down-Queues-Alert.txt exists!!!"
         exit 1

else
         echo "No file with the name $FX_ENV-fx-Down-Queues-Alert.txt exists, so skiping script break execution!!!"
         #exit 1
fi

echo 'Script execution is done.'
