 How to run the this script.
 
 Prerequisite 
 1. AWS command-line(CLI) install
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
 2. Need to have secret-key and access-key. Session-token will be generate by shell script        
 
 #Syntax: bash api-gateway-registration.sh --host "<Hostname or IP>"  --username "<USERNAME>"  --password "<PASSWORD>"  --accesskey "<ACCESS_KEY>" --secretkey "<SECRET_KEY>" --name "<NAME>"  --accountType "<ACCOUNT_TYPE>"  --region "<REGION>"

#Example usage: bash api-gateway-registration.sh   --host "cloud.apisec.ai" --username "admin@apisec.ai" --password "xxxxxx" --accesskey "xxxxxxx" --secretkey "xxxxxxxxx" --name "Testing"  --accountType "AWS_API_GATEWAY"  --region "us-east-1" 
