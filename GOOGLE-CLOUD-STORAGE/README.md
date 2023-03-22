Follow this link to generate JSON Key file https://cloud.google.com/iam/docs/keys-create-delete#iam-service-account-keys-create-console

Here is the sample json key
```
{
  "type": "service_account",
  "project_id": "gcp-report-storage-xxxxx",
  "private_key_id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "private_key": "-----BEGIN PRIVATE KEY-----\k=\n-----END PRIVATE KEY-----\n",
  "client_email": "github-sa@gcp-report-storage-xxxxx.iam.gserviceaccount.com",
  "client_id": "xxxxxxxx",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/github-sa%40gcp-report-storage-xxxxx.iam.gserviceaccount.com"
}
```
Once generate JSON key file save into text/notepad with .json extension like gcp.json 

How to run the script.
```
#Syntax: bash api-gateway-registration.sh --host "" --username "" --password "" --reportaccesscredentials "<JSON_FILE>" --bucketName "<BUCKET_NAME>" --name "<GCP_NAME" --accountType "<ACCOUNT_TYPE>" 

#Example usage: bash gcp-report-storage.sh --host "https://cloud.apisec.ai" --username "admin@apisec.ai" --password "xxxxxx" --reportaccesscredentials "./gcp.json" --bucketName "gcpreportstorage" --name "GCP-Report-Storage" --accountType "GOOGLE_CLOUD_STORAGE"
```
