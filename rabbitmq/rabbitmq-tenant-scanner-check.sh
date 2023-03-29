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
scannersFailCount=0    

queue_names=$(jq -r '.name' <<< "$data")
queue_consumers=$(jq -r '.consumers' <<< "$data")
queue_messages=$(jq -r '.messages' <<< "$data")
tenant=$(echo $FX_TENANT | tr ' ' '-')
queues=$(paste -d':' <(printf '%s\n' "${queue_names}") <(printf '%s\n' "${queue_consumers}") <(printf '%s\n' "${queue_messages}"))

queues=$( echo "$queues" | sed 's/ /%20/g' )

for scan in ${queues}

do
    qName=$(echo "$scan" | cut -d: -f1)
    oName=$(echo "$qName" | cut -d- -f2)  
    orgCharCount=${#oName}
    charsRemove=0
    charsRemove=`expr $orgCharCount + 10` 
    oName=$(printf "%b\n" "${oName//%/\\x}")
    sName=${qName::-6}
    sName=${sName:$charsRemove}
    sName=$(printf "%b\n" "${sName//%/\\x}")
    qName=$(printf "%b\n" "${qName//%/\\x}")
    oName=$(printf "%b\n" "${oName//%/\\x}")
    qCount=$(echo "$scan" | cut -d: -f2)
    qMessages=$(echo "$scan" | cut -d: -f3)
    if [ "$FX_TENANT" == "$oName" ]; then
         
         if [ $qCount -eq 0 ]; then
             if [ $ilinecount -eq 0  ]; then
                 echo "Following APIsec $FX_ENV Environment Scanners of '$FX_TENANT' Tenant are down/not working properly as there queues have zero consumers count. Devops team please take appropriate action!!!" > $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
                 dat=$(date -u)
                 echo "$dat" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
                 echo " " >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
                 ilinecount=`expr $ilinecount + 1`
             fi
             echo "Org-Name: $oName" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             echo "Scanner-Name: $sName" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             echo "ConsumersCount: $qCount" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             echo "Total Messages In '$sName' Scanner Queue: $qMessages" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             echo "Queue-Name: $qName" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             echo " " >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
             scannersFailCount=`expr $scannersFailCount + 1`
         fi
    fi
done

if [ $scannersFailCount -gt 0 ]; then
      echo " " >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
      echo "Total no. of APIsec $FX_ENV Environment Scanners of '$FX_TENANT' Tenant Down/Not-Working  are: $scannersFailCount" >> $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
fi

if [ -s $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt ]; then
         echo "file $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt exits"
         cat $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt
         echo " "
         echo "Breaking script execution as the file with the name $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt exists!!!"
         exit 1
else
         echo "Skipping script break execution as no file with the name $FX_ENV-$tenant-Tenant-Down-Scanners-Alert.txt exists!!!"
         #exit 1
fi

echo 'Script execution is done.'
