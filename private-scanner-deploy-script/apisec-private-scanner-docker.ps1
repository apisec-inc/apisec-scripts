param ($hostName ="cloud.apisec.ai",
$scannerName,
$fxIam,
$fxKey,
$portNumber="5671",
$fxSSL="true",
$imageTag="latest",
$concurrentConsumers,
$maxConcurrentConsumers,
$delay)

$FX_HOST=$hostName
$FX_SCANNER_NAME=$scannerName
$FX_IAM=$fxIam
$FX_KEY=$fxKey
$FX_PORT=$portNumber
$FX_SSL=$fxSSL
$FX_IMAGE_TAG=$imageTag
$FX_CONCURRENT_CONSUMERS=$concurrentConsumers
$FX_MAX_CONCURRENT_CONSUMERS=$maxConcurrentConsumers
$FX_DELAY=$delay

Write-Host "Press '1' to Deploy  APIsec Scanner!!"
Write-Host "Press '2' to Restart APIsec Scanner!!"
Write-Host "Press '3' to Refresh APIsec Scanner!!"

$Option= Read-Host "Enter Your Option"


if ($Option -eq "1" ){
      $checkScanner= docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME"
      if ($checkScanner -ne $null) {
                 Write-Host " "
                 Write-Host "Docker Container/Scanner with '$FX_SCANNER_NAME' name already exists!!"
      }
      else  {
                 Write-Host "Deploying '$FX_SCANNER_NAME'  Scanner!!"
                 docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                 sleep 10
                 docker ps
                 Write-Host " "
                 Write-Host "'$FX_SCANNER_NAME' Scanner Deployment is successfully completed!!"
      }
}
elseif ($Option -eq "2" ){

      $checkScanner= docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME"
      if ($checkScanner -ne $null) {
                 Write-Host "Restarting  '$FX_SCANNER_NAME'  Scanner!!"
                 docker restart $FX_SCANNER_NAME
                 sleep 5
                 docker ps
                 Write-Host " "
                 Write-Host "'$FX_SCANNER_NAME' Scanner is successfully restarted!!"
      }
      else  {
                Write-Host  " "
                Write-Host "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to restart. Please Deploy it!!"
      }


}

elseif ($Option -eq "3" ){

      $checkScanner= docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME"
      if ($checkScanner -ne $null) {
                 Write-Host "Refreshing  '$FX_SCANNER_NAME'  Scanner!!"
                 docker rm -f $FX_SCANNER_NAME
                 sleep 5
                 docker pull apisec/scanner:$FX_IMAGE_TAG
                 docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL  apisec/scanner:$FX_IMAGE_TAG
                 sleep 10
                 docker ps
                 Write-Host " "
                 Write-Host "'$FX_SCANNER_NAME' Scanner is successfully refreshed!!"
      }
      else  {
                Write-Host  " "
                Write-Host "No Docker Container/Scanner with '$FX_SCANNER_NAME' name exists to refresh. Please Deploy it!!"
      }
}

else  {
         Write-Host " "
         Write-Host "Entered Option: $option"
         Write-Host "You Didn't specify correct option. Please rerun the script again and specify right option based on your requirement!!"
}
