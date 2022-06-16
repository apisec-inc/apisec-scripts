param ($url ="https://cloud.fxlabs.io",
$username,
$password,
$project,
$profile,
$scanner,
$emailReport,
$reportType,
$tags="")

$FX_HOST=$url
$FX_USER=$username
$FX_PWD=$password
$FX_PROJECT_NAME=$project
$JOB_NAME=$profile
$REGION=$scanner
$FX_EMAIL_REPORT=$emailReport
$FX_REPORT_TYPE=$reportType
$FX_TAGS=$tags


#Write-Host "user = ${FX_USER}"
#Write-Host "region = ${REGION}"
#Write-Host "projectName = ${FX_PROJECT_NAME}"
#Write-Host "jobName = ${JOB_NAME}"
#Write-Host "hostname = ${FX_HOST}" 

$FX_SCRIPT=""

if ($FX_TAGS -ne "") {

    FX_SCRIPT="&tags=script:"+${FX_TAGS}
}

$params = @{"username"=$FX_USER;
"password"=$FX_PWD;
}

$token=$((Invoke-WebRequest  -Uri "${FX_HOST}/login" -UseBasicParsing -Method POST -Body ($params|ConvertTo-Json) -ContentType "application/json;charset=UTF-8" ) | ConvertFrom-Json  | select -expand token)
Write-Host "generated token is: = ${token}"

$bearerAuthValue = "Bearer $token"
$headers = @{Authorization = $bearerAuthValue}

$URL="${FX_HOST}/api/v1/runs/project/${FX_PROJECT_NAME}?jobName=${JOB_NAME}&region=${REGION}&emailReport=${FX_EMAIL_REPORT}&reportType=${FX_REPORT_TYPE}${FX_SCRIPT}"

$runId=$((Invoke-WebRequest  -Uri $URL -UseBasicParsing   -Headers $headers  -Method POST  -ContentType "application/json;charset=UTF-8" ) | ConvertFrom-Json  | select -expand data | select -expand id)

Write-Host "runId = $runId"
Write-Host " "


if (  !$runId )
{

	  Write-Host "RunId =  "$runId""
          Write-Host "Invalid runid"
      
          Write-Host $((Invoke-WebRequest  -Uri $URL -UseBasicParsing   -Headers $headers  -Method POST  -ContentType "application/json;charset=UTF-8" ) | ConvertFrom-Json  | select -expand data | select -expand id)

          exit 1
}

$taskStatus="WAITING"
Write-Host "taskStatus =  $taskStatus"

While ( ("$taskStatus" -eq "WAITING") -or ("$taskStatus" -eq "PROCESSING") )
{ 
               	 sleep 5
                 
	       	 Write-Host "Checking Status...."
                
                  $passPercent=$((Invoke-WebRequest  -Uri "${FX_HOST}/api/v1/runs/${runId}"  -UseBasicParsing -Headers $headers -Method GET  -ContentType "application/json;charset=UTF-8" )| ConvertFrom-Json  | select -expand data | select -expand ciCdStatus)


                
                  $array = $passPercent.Split(':')			
                  $taskStatus= $array[0]
			
                  Write-Host "Status =" , $array[0], " Success Percent =" , $array[1], " Total Tests =", $array[2], " Total Failed =", $array[3], " Run =" $array[6]

                  if ("$taskstatus" -eq "COMPLETED"){
                  
                       Write-Host "------------------------------------------------"
                       Write-Host "Run detail link ${FX_HOST}"
                       Write-Host  $array[7] 
                       Write-Host "------------------------------------------------"
                       Write-Host "Scan Successfully Completed"
                       exit 0       
                                                   }
} 

if ("$taskstatus" -eq "TIMEOUT")
{
Write-Host "Task Status = $taskstatus" 
exit 1
}


Write-Host $(Invoke-WebRequest  -Uri "${FX_HOST}/api/v1/runs/${runId}" -UseBasicParsing -Headers $headers -Method GET  -ContentType "application/json;charset=UTF-8" )
exit 1

return 0