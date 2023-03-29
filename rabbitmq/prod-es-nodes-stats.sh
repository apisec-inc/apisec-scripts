#!/bin/bash
# Begin
test="In_progress"

while [ "$test" == "In_progress" ]

       do
             sleep 10
             mCount=0
             dat=$(date -u)
             data=$(kubectl exec -it elasticsearch-es-default-0 -- curl -s -X GET 'http://localhost:9200/_nodes/stats' | jq -r '.[]' | sed 1,6d)
             nodeNames=$(jq -r '.[]|.name' <<< "$data")
             jvm=$(jq -r '.[]|.jvm.mem' <<< "$data")
             heapUse=$(jq -r '.[]|.jvm.mem.heap_used_in_bytes' <<< "$data")
             heapUsePerc=$(jq -r '.[]|.jvm.mem.heap_used_percent' <<< "$data")

             completeString=$(paste -d':' <(printf '%s\n' "${nodeNames}") <(printf '%s\n' "${heapUse}") <(printf '%s\n' "${heapUsePerc}"))
             echo " "
            #  echo "$completeString"
            #  echo " "

             for scan in ${completeString}
                do
                    nodeName=$(echo "$scan" | cut -d: -f1)
                    heapUsed=$(echo "$scan" | cut -d: -f2)
                    heapUsePerct=$(echo "$scan" | cut -d: -f3)

                    echo "$dat"
                    echo "NodeName: $nodeName"
                    echo "heap_memory_used_in_bytes: $heapUsed"
                    echo "heap_memory_used_percent: $heapUsePerct"
                    echo "Complete String: $scan"
                    echo " "

                    if [ $heapUsePerct -gt 75 ]; then

                         if [ $mCount -eq 0 ]; then
                              echo "Heap Memory Usage of below elasticsearch is more than 75%" > Prod-ES-Nodes-HeapMemoryUsage.txt
                              echo "$dat" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                              echo " " >> Prod-ES-Nodes-HeapMemoryUsage.txt
                              echo "$completeString" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                              echo " " >> Prod-ES-Nodes-HeapMemoryUsage.txt
                              mCount=`expr $mCount + 1`
                         fi

                          echo "NodeName: $nodeName" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                          echo "heap_memory_used_in_bytes: $heapUsed" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                          echo "heap_memory_used_percent: $heapUsePerct" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                          echo " " >> Prod-ES-Nodes-HeapMemoryUsage.txt
                          echo "Complete String: $scan" >> Prod-ES-Nodes-HeapMemoryUsage.txt
                          echo " " >> Prod-ES-Nodes-HeapMemoryUsage.txt
                    fi

               done

               if [ -s Prod-ES-Nodes-HeapMemoryUsage.txt ]; then
                     echo "File Prod-ES-Nodes-HeapMemoryUsage.txt exists, so stoping script execution!!"
                     exit 0
               fi

       done


