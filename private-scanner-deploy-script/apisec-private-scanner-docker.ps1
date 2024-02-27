param ($host ="cloud.apisec.ai",
$scannerName,
$fxIam,
$fxKey,
$portNumber="5671",
$fxSSL="true",
$imageTag="latest",
$concurrentConsumers,
$maxConcurrentConsumers,
$delay)

$FX_HOST=$host
$FX_SCANNER_NAME=$scannerName
$FX_IAM=$fxIam
$FX_KEY=$fxKey
$FX_PORT=$portNumber
$FX_SSL=$fxSSL
$FX_IMAGE_TAG=$imageTag
$FX_CONCURRENT_CONSUMERS=$concurrentConsumers
$FX_MAX_CONCURRENT_CONSUMERS=$maxConcurrentConsumers
$FX_DELAY=$delay

if ($FX_DELAY -ne "" -and $FX_CONCURRENT_CONSUMERS -ne "" -and $FX_MAX_CONCURRENT_CONSUMERS -ne "") {
    Write-Host "Deploying Rate-Limiting Scanner with Delay: $FX_DELAY, concurrentCoumsers: $FX_CONCURRENT_CONSUMERS and maxConcurrentConsumers: $FX_MAX_CONCURRENT_CONSUMERS"
    deleteScanner=$(docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME")
    if ($deleteScanner -ne ""){
        docker rm -f $FX_SCANNER_NAME
    }
    docker pull apisec/scanner:$FX_IMAGE_TAG
    docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
    sleep 10
    docker ps
}
elseif ( $FX_CONCURRENT_CONSUMERS -ne "" -and $FX_MAX_CONCURRENT_CONSUMERS -ne "") {
    Write-Host "Deploying Scanner with concurrentCoumsers: $FX_CONCURRENT_CONSUMERS and maxConcurrentConsumers: $FX_MAX_CONCURRENT_CONSUMERS"
    deleteScanner=$(docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME")
    if ($deleteScanner -ne ""){
        docker rm -f $FX_SCANNER_NAME
    }
    docker pull apisec/scanner:$FX_IMAGE_TAG
    docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
    sleep 10
    docker ps
}
else{
    deleteScanner=$(docker ps -a | Select-String -Pattern "$FX_SCANNER_NAME")
    if ($deleteScanner -ne ""){
        docker rm -f $FX_SCANNER_NAME
    }
    docker pull apisec/scanner:$FX_IMAGE_TAG
    docker run --name $FX_SCANNER_NAME -d -e FX_HOST=$FX_HOST -e FX_IAM=$FX_IAM -e FX_KEY=$FX_KEY -e FX_PORT=$FX_PORT -e FX_SSL=$FX_SSL -e concurrentConsumers=$FX_CONCURRENT_CONSUMERS -e maxConcurrentConsumers=$FX_MAX_CONCURRENT_CONSUMERS -e delay=$FX_DELAY apisec/scanner:$FX_IMAGE_TAG
    sleep 10
    docker ps
}
