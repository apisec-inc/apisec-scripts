#!/bin/bash

rm -rf PSQL-Long-Running-Queries-List.txt
psqlData=$(kubectl exec -i fx-postgres-0 -- psql 'postgresql://username:password@hostname/database-name' -c "SELECT pid, user, pg_stat_activity.query_start, now() - pg_stat_activity.query_start AS query_time, query, state, wait_event_type, wait_event FROM pg_stat_activity WHERE (now() - pg_stat_activity.query_start) > interval '5 minutes' AND state = 'active';";)
connectionsData=$(kubectl exec -i fx-postgres-0 -- psql 'postgresql://username:password@hostname/database-name' -c 'select  * from (select count(*) used_conn from pg_stat_activity) q1, (select setting::int res_for_super from pg_settings where name=$$superuser_reserved_connections$$) q2, (select setting::int max_conn from pg_settings where name=$$max_connections$$) q3;';)
firstLine=$(echo "$psqlData" | sed -n '1p')
secondLine=$(echo "$psqlData" | sed -n '2p')
count=0
echo "$psqlData"
echo " "
mPsqlData=$(echo "$psqlData" | sed -n '1!p' | sed -n '1!p' | sed 's/|/\t/g' | sed 's/ /%20/g' | sed 's/\t/^/g')

for line in $mPsqlData
    do
         query=$(echo "$line" | cut -d^ -f5)
         mQuery=$(echo "$query" | sed 's/%20/ /g')
         #if  [[ $mQuery != *"START_REPLICATION"* ]] && [[ $mQuery != *"VACUUM"* ]]; then
         #if  [[ $mQuery != *"START_REPLICATION"* ]] && [[ $mQuery != *"VACUUM"* ]] && [[ $mQuery != *"row"* ]]; then
         if  [[ $mQuery != *"START_REPLICATION"* ]]  && [[ $mQuery != *"row"* ]] && [[ $mQuery != *"rows"* ]]; then
         #if  [[ $mQuery == *"START_REPLICATION"* ]]; then

                if [ $count -eq 0 ]; then
                     echo "APIsec Platform PSQL Long Running Queiries In 'Active' state in Prod Environment!!" > PSQL-Long-Running-Queries-List.txt
                     dat=$(date)
                     echo "Date & Time: $dat" >> PSQL-Long-Running-Queries-List.txt
                     echo " " >> PSQL-Long-Running-Queries-List.txt
                     echo "$firstLine" >> PSQL-Long-Running-Queries-List.txt
                     echo "$secondLine" >> PSQL-Long-Running-Queries-List.txt
                fi
                oLine=$(echo $line | sed 's/%20/ /g' |  tr '^' '|')
                echo "Complete-Psql-Query"
                echo "$mQuery"
                echo " "
                echo "$oLine"
                echo "$oLine" >> PSQL-Long-Running-Queries-List.txt
                count=`expr $count + 1`
                echo " Iteration No: $count"
                echo " "
         fi
    done
echo " "
if  [ -s PSQL-Long-Running-Queries-List.txt ]; then
       echo "PSQL-Long-Running-Queries-List.txt File exists"
       echo " " >> PSQL-Long-Running-Queries-List.txt
       echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" >> PSQL-Long-Running-Queries-List.txt
       echo " " >> PSQL-Long-Running-Queries-List.txt
       echo "--------------------------------------" >> PSQL-Long-Running-Queries-List.txt
       echo "Current Database Connections Status" >> PSQL-Long-Running-Queries-List.txt
       echo "--------------------------------------" >> PSQL-Long-Running-Queries-List.txt
       echo "$connectionsData" >> PSQL-Long-Running-Queries-List.txt
       echo "--------------------------------------" >> PSQL-Long-Running-Queries-List.txt
       echo " " >> PSQL-Long-Running-Queries-List.txt
       echo "Script Execution is done!!" >> PSQL-Long-Running-Queries-List.txt
       cat PSQL-Long-Running-Queries-List.txt
       echo " "
else
       echo "PSQL-Long-Running-Queries-List.txt File Doesn't exists, so breaking script execution and failing jenkins job!!"
       echo " "
       exit 1
fi
