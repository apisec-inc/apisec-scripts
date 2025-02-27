# Running APIsec Scanner as a jar
## Prerequisite: 
Java-17 and FX_HOST, FX_IAM & FX_KEY values from the APIsec scanner.


Please use the following commands to deploy the APIsec Scanner as a jar file. Make sure to replace the placeholders <FX_HOST>, <FX_IAM>, and <FX_KEY> with the actual values.

You can obtain these values from the Scanner Module page after logging into the APIsec portal.

##  on Windows machine with Powershell.
Step 1: Download The Powershell script

    wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/refs/heads/master/scanner-jar/Scanner_Jar_Deployment.ps1  -O Scanner_Jar_Deployment.ps1
    
Step 2: Run The Downloaded Powershell Script.

    powershell -File Scanner_Jar_Deployment.ps1 -fx_host "<FX_HOST>" -fx_iam "<FX_IAM>" -fx_key "<FX_KEY>" -fx_port "443"


## on Ubuntu machine.
Step 1: Download The Bash Script

    wget https://raw.githubusercontent.com/apisec-inc/apisec-scripts/refs/heads/master/scanner-jar/Scanner_Jar_Deployment.sh -O Scanner_Jar_Deployment.sh

Step 2: Run The Downloaded Bash Script.

    bash Scanner_Jar_Deployment.sh --fx-host "<FX_HOST>" --fx-iam "<FX_IAM>" --fx-key "<FX_KEY>"
    

Please refer to the following documentation for detailed instructions on creating a scanner instance in APIsec product: https://cloud.apisec.ai 
https://docs.apisec.ai/DeployScanners/
