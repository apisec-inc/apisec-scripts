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

data=$(curl -s --request GET --user $FX_USER:$FX_PWD --url $FX_HOST/api/queues | jq -r '.[]')
queue_names=$(jq -r '.name' <<< "$data")
queue_consumers=$(jq -r '.consumers' <<< "$data")
queue_messages=$(jq -r '.messages' <<< "$data")


queues=$(paste -d':' <(printf '%s\n' "${queue_names}") <(printf '%s\n' "${queue_consumers}") <(printf '%s\n' "${queue_messages}"))
queues1=$( echo "$queues" | sed 's/ /%20/g' )


cslinecount=0
tFailQueueCount=0
cScannerFailCount=0


for scan in ${queues1}
    do          
                        if [[ $scan == *"APIsec"* ]] || [[ $scan == *"FX-Demo"* ]]  || [[ $scan == *"fx"* ]] || [[ $scan == *"QA"* ]] || [[ $scan == *"spring"* ]] || [[ $scan == *"NetBanking"* ]]; then
                              echo "Skiping it" > /dev/null
                        else
                                 qName=$(echo "$scan" | cut -d: -f1)  
                                 oName=$(echo "$qName" | cut -d- -f2) 
                                 qCount=$(echo "$scan" | cut -d: -f2)    
                                 qMessages=$(echo "$scan" | cut -d: -f3)                               
                                 #sName=$(echo "$qName" | tr '%20' ' ' )

                                 orgCharCount=${#oName}
                                 charsRemove=0
                                 charsRemove=`expr $orgCharCount + 10`

                                 sName=${qName::-6}
                                 sName=${sName:$charsRemove}

                                 qName=$(printf "%b\n" "${qName//%/\\x}")
                                 sName=$(printf "%b\n" "${sName//%/\\x}")
                                 oName=$(printf "%b\n" "${oName//%/\\x}")
                    
                                 if [ $qCount -eq 0 ]; then
                                     if [ $cslinecount -eq 0 ]; then
                                           dat=$(date -u)                                                                                 
                                           echo "Following APIsec $FX_ENV Customer Private Scanners are Down or not working properly as there queues have zero consumers count, CustomerSupport and Devops team, please take appropriate action!!!" > $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                           echo "$dat" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                           echo " " >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                           cslinecount=`expr $cslinecount + 1`  
                                      fi
                                      tFailQueueCount=`expr $tFailQueueCount + 1`
                                      echo "Fail Queue Count No: $tFailQueueCount"
                                      echo "Tenant/Org-Name: $oName"
                                      echo "QueueName: $qName"
                                      echo "ScannerName: $sName"
                                      echo "ConsumersCount: $qCount"
                                      echo "MessagesCount: $qMessages"
                                      echo " "  


                                      echo "Tenant/Org-Name: $oName" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt                                     
                                      echo "Scanner-Name: $sName" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                      echo "Scanner-Consumers-Count: $qCount" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                      echo "Total Messages In '$sName' Scanner Queue: $qMessages" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                      echo "Queue-Name: $qName" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
                                      echo " " >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt 
                                      cScannerFailCount=`expr $cScannerFailCount + 1`              
                                 fi


                        fi

    done  


if [ $cScannerFailCount -gt 0 ]; then
      echo " " >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
      echo "Total no. of $FX_ENV Customer Private Scanners Down/Not-Working  are: $cScannerFailCount" >> $FX_ENV-Customer-Private-Scanners-Down-Status.txt
fi
 
if  [ -s $FX_ENV-Customer-Private-Scanners-Down-Status.txt ]
        then
             echo "file exits"
             cat $FX_ENV-Customer-Private-Scanners-Down-Status.txt
             echo " "
        else
             echo "Breaking script execution as no file with the name $FX_ENV-Customer-Private-Scanners-Down-Status.txt exists!!!"
             exit 1
fi

echo 'Script execution is done.'
exit 0

