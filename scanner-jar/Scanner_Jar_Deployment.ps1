# .\Scanner_Jar_Deployment.ps1 -fx_host "your-fx-host" -fx_key "your-fx-key" -fx_iam "your-fx-iam"

param(
    [string]$fx_host,
    [string]$fx_key,
    [string]$fx_iam
)

$botJarUrl = "https://raw.githubusercontent.com/apisec-inc/apisec-scripts/refs/heads/master/scanner-jar/bot.jar"
$botJarPath = ".\bot.jar"
$Env:SPRING_AMQP_DESERIALIZATION_TRUST_ALL = "true"
$Env:FX_HOST = $fx_host
$Env:FX_KEY = $fx_key
$Env:FX_IAM = $fx_iam

Write-Host "Downloading bot.jar..."
Invoke-Expression ("curl -o " + $botJarPath + " " + $botJarUrl)

if (Test-Path $botJarPath) {
    Write-Host "bot.jar downloaded successfully."
} else {
    Write-Error "Failed to download bot.jar."
    exit 1
}

Write-Host "Running bot.jar with parameters: fx-host=$fx_host, fx-key=$fx_key, fx-iam=$fx_iam"
java -jar $botJarPath