#!/bin/bash
rm -rf /opt/apisecfree-dailymail/APIsecFree-Prod-DailyMail.txt
yester=$(date -d '-1 day' "+%F")
mongoDbId=$(docker ps | grep mongodb | awk '{print $1}')
echo "MongoDBClient-DockerContainerID: $mongoDbId"
echo ""
data=$(docker exec -i $mongoDbId mongosh "mongodb+srv://username:xxxxxxxxxx@serverlesspentestdb.bu2mw.mongodb.net/db-name?retryWrites=true&w=majority" --quiet --eval 'EJSON.stringify(db.apiseccheck.find({ "submittedAt": { $gt: ISODate("2023-10-06T00:00:00.000Z") }, "email": { $not: { $regex: /@(apisec\.com|apisec\.ai)$/i } } }).toArray())' | jq .[])

#data=$(cat apisecfreeproddb.json | jq '.[]')
projName=$(echo "$data" | jq -r '.projectName')
projStatus=$(echo "$data" | jq -r '.status')
email=$(echo "$data" | jq -r '.email')
subDate=$(echo "$data" | jq -r '.submittedAt."$date"')
totalPlaybooks=$( echo "$data" | jq -r '.result.specAnalysis.totalPlaybooks')
totalEndpoints=$( echo "$data" | jq -r '.result.specAnalysis.totalEndpoints')
displayStatus=$(echo "$data" | jq -r '.displayStatus')
isBaseURLReachable=$(echo "$data" | jq -r '.isBaseURLReachable')
dateTested=$(echo "$data" | jq -r '.result.dateTested."$date"')
dateCompleted=$(echo "$data" | jq -r '.result.dateCompleted."$date"')
totalTestsExecuted=$(echo "$data" | jq -r '.result.testSummary.totalTestsExecuted')
totalTestsPassed=$(echo "$data" | jq -r '.result.testSummary.testsPassed')
totalTestsFailed=$(echo "$data" | jq -r '.result.testSummary.testsFailed')
vulnerabilitiesFound=$(echo "$data" | jq -r '.result.testSummary.vulnerabilitiesFound')



mData=$(paste -d'=' <(printf '%s\n' "${projName}") <(printf '%s\n' "${projStatus}") <(printf '%s\n' "${email}") <(printf '%s\n' "${subDate}") <(printf '%s\n' "${totalEndpoints}") <(printf '%s\n' "${totalPlaybooks}") <(printf '%s\n' "${displayStatus}") <(printf '%s\n' "${isBaseURLReachable}") <(printf '%s\n' "${dateTested}") <(printf '%s\n' "${dateCompleted}") <(printf '%s\n' "${totalTestsExecuted}") <(printf '%s\n' "${totalTestsPassed}") <(printf '%s\n' "${totalTestsFailed}") <(printf '%s\n' "${vulnerabilitiesFound}"))
mData=$(echo "$mData" | sed 's/ /%20/g')

count=0
for scan in ${mData}
do
     projectName1=$(echo $scan | cut -d= -f1)
     projectName=$(echo $projectName1  | sed  's/%20/ /g')
     projectStatus=$(echo $scan | cut -d= -f2)
     email=$(echo $scan | cut -d= -f3)
     SubmittedDate=$(echo $scan | cut -d= -f4)
     tEndpoints=$(echo $scan | cut -d= -f5)
     tPlaybooks=$(echo $scan | cut -d= -f6)
     disStatus=$(echo $scan | cut -d= -f7)
     mDisStatus=$(echo $disStatus | sed  's/%20/ /g')
     mIsBaseURLReachable=$(echo $scan | cut -d= -f8)
     dateTested=$(echo $scan | cut -d= -f9)
     dateCompleted=$(echo $scan | cut -d= -f10)
     totalTestsExecuted=$(echo $scan | cut -d= -f11)
     testsPassed=$(echo $scan | cut -d= -f12)
     testsFailed=$(echo $scan | cut -d= -f13)
     vulnerabilitiesFound=$(echo $scan | cut -d= -f14)



     #testSummary2=$(echo $testSummary1  | sed  's/%20/ /g')
     if [ $count -eq 0 ]; then
          echo "APIsecFree Daily Mail for list of  Regsitered Projects since $yester in Prod" > APIsecFree-Prod-DailyMail.txt
          dat=$(date)
          echo "Date & Time: $dat" >> APIsecFree-Prod-DailyMail.txt
          echo " " >> APIsecFree-Prod-DailyMail.txt
     fi

     count=`expr $count + 1`
     echo "$scan"
     echo "ProjectName: $projectName"
     echo "Status: $projectStatus"
     echo "DisplayStatus: $mDisStatus"
     echo "Email: $email"
     echo "SubmittedDate: $SubmittedDate"
     echo "TotalEndPoints: $tEndpoints"
     echo "TotalPlaybooks: $tPlaybooks"
     echo "isBaseURLReachable: $mIsBaseURLReachable"
     echo "datedTested: $dateTested"
     echo "datedCompleted: $dateCompleted"
     echo "totalTestsExecuted: $totalTestsExecuted"
     echo "testsPassed: $testsPassed"
     echo "testsFailed: $testsFailed"
     echo "vulnerabilitiesFound: $vulnerabilitiesFound"



     echo " "

     echo "ProjectName: $projectName" >> APIsecFree-Prod-DailyMail.txt
     echo "Status: $projectStatus" >> APIsecFree-Prod-DailyMail.txt
     echo "DisplayStatus: $mDisStatus" >> APIsecFree-Prod-DailyMail.txt
     echo "Email: $email" >> APIsecFree-Prod-DailyMail.txt
     echo "SubmittedDate: $SubmittedDate" >> APIsecFree-Prod-DailyMail.txt
     echo "TotalEndPoints: $tEndpoints" >> APIsecFree-Prod-DailyMail.txt
     echo "TotalPlaybooks: $tPlaybooks" >> APIsecFree-Prod-DailyMail.txt
     echo "isBaseURLReachable: $mIsBaseURLReachable" >> APIsecFree-Prod-DailyMail.txt

     if [ "$dateTested" == null   ]; then
           echo "datedTested: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "datedTested: $dateTested" >> APIsecFree-Prod-DailyMail.txt
     fi

     if [ "$dateCompleted" == null   ]; then
           echo "datedCompleted: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "dateCompleted: $dateCompleted" >> APIsecFree-Prod-DailyMail.txt
     fi

     if [ "$totalTestsExecuted" == null   ]; then
           echo "totalTestsExecuted: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "totalTestsExecuted: $totalTestsExecuted" >> APIsecFree-Prod-DailyMail.txt
     fi


     if [ "$testsPassed" == null   ]; then
           echo "testsPassed: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "testsPassed: $testsPassed" >> APIsecFree-Prod-DailyMail.txt
     fi

     if [ "$testsFailed" == null   ]; then
           echo "testsFailed: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "testsFailed: $testsFailed" >> APIsecFree-Prod-DailyMail.txt
     fi

     if [ "$vulnerabilitiesFound" == null   ]; then
           echo "vulnerabilitiesFound: Scan Not Yet Triggered" >> APIsecFree-Prod-DailyMail.txt
     else
           echo "vulnerabilitiesFound: $vulnerabilitiesFound" >> APIsecFree-Prod-DailyMail.txt
     fi

     echo " " >> APIsecFree-Prod-DailyMail.txt
done
if [ $count -gt 0 ]; then
    echo "Total No of projects register since $yester in APIsecFree Prod are: $count" >> APIsecFree-Prod-DailyMail.txt
    echo "Total No of projects register since $yester in APIsecFree Prod are: $count"
fi
echo " "
echo "Script Execution is Done!!"

