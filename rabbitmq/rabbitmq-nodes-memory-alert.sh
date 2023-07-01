#!/bin/bash
# Begin
TEMP=$(getopt -n "$0" -a -l "host:,username:,password:,project:,profile:,scanner:,environment:,emailReport:,reportType:,tags:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
		    --host) FX_HOST="$2"; shift;;
                    --username) FX_USER="$2"; shift;;
                    --environment) FX_ENV="$2"; shift;;
                    --password) FX_PWD="$2"; shift;;
                    --) shift;;
             esac
             shift;
    done


if [ "$FX_HOST" = "" ];
then
FX_HOST="https://cloud.apisec.ai/rabbit"
fi

status=$(curl -sI $FX_HOST | sed -n '1p' | awk '{print $2}')

if [ $status -eq 200 ]; then


     data=$(curl -s --request GET --user $FX_USER:$FX_PWD --url $FX_HOST/api/nodes)
     ilinecount=0 
     mqFailNodeCount=0    
     #nodes_names=$(jq -r '.name' <<< "$data")
     #nodes_status=$(jq -r '.running' <<< "$data")           
     #queues=$(paste -d':' <(printf '%s\n' "${nodes_names}") <(printf '%s\n' "${nodes_status}"))
     #echo "$queues"

     readarray -t rData < <(echo "$data" | jq -c '.[]')

     #echo $data | jq -r .

     #for runId in "${rData[@]}"

     for scan in "${rData[@]}"

         do
               #mqNodeName=$(echo "$scan" | cut -d: -f1 | cut -f1 -d\. | cut -d@ -f2)
               #mqNodeStatus=$(echo "$scan" | cut -d: -f2)
               mqName=$(echo "$scan" | jq -r '.name')
               mqNodeName=$(echo "$mqName" | cut -d: -f1 | cut -f1 -d\. | cut -d@ -f2)
               mqNodeStatus=$(echo "$scan" | jq -r '.running')
               mqNodeMemAlarm=$(echo "$scan" | jq -r '.mem_alarm')
               mqNodeMemLimit=$(echo "$scan" | jq -r '.mem_limit')
               mqNodeMemUsed=$(echo "$scan" | jq -r '.mem_used')
    
               if [ $mqNodeMemAlarm == "true" ]; then

                    if [ $ilinecount -eq 0 ]; then
                         dat=$(date -u)
                         echo "Following $FX_ENV Environment Rabbitmq Nodes Memory Utilization is beyond watermark memory limit. Devops team please take appropriate action!!!" > $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                         echo "$dat" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                         ilinecount=`expr $ilinecount + 1` 
                    fi
                    echo " " >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                    echo "Rabbitmq-Node-Name: $mqNodeName" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                    echo "Rabbitmq-Node-Running-Status: $mqNodeStatus" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                    echo "Rabbitmq-Node-Mem-Limit: $mqNodeMemLimit" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                    echo "Rabbitmq-Node-Mem-Used: $mqNodeMemUsed" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
                    echo "Rabbitmq-Node-Mem-Alarm: $mqNodeMemAlarm" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt

                    mqFailNodeCount=`expr $mqFailNodeCount + 1`       
               fi
         done
     
     if [ $mqFailNodeCount -gt 0 ]; then
          echo " " >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
          echo "Total no. of APIsec $FX_ENV Environment Rabbitmq Nodes' Memory Utilization beyond watermark memory limit  are: $mqFailNodeCount" >> $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt
     fi

     if [ -s $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt ]; then
             echo "file $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt exits"
             cat $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt 
             echo " "
             echo "Breaking script execution as the file with the name $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt  exists!!!"
             exit 1

     else
             echo "Skipping script break execution as no file with the name $FX_ENV-Rabbitmq-Nodes-MemoryThreshold-Alert.txt exists!!!"
             #exit 1
     fi

elif [ $status -eq 503 ]; then
       echo "Rabbitmq Nodes/services are down"
       exit 1
fi

echo 'Script execution is done.'

