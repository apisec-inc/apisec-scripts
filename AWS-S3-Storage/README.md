# How to Run the ```apisec_s3_storage_vault.sh``` for different use-cases and how script flow of execution will be with that use-case.

##       Use-Case 1: To Create/Update a AWS_S3 Storage Vault.
       Script flow of execution: Script will create a AWS S3 storage vault if no vault account with that name exists. 
                                 If a vault account exists with that name then it will update the vault account if it is of type ```AWS_S3```
       
       Syntax:        bash apisec_s3_storage_vault.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --vaultAccountName <vault_name>         --accessKey <AWS_Access_Key>   --secretKey <AWS_Secret_Key>                       --bucketName <S3_Bucket_Name>     --bucketRegion <S_Bucket_Region>
       Example-Usage: bash apisec_s3_storage_vault.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --vaultAccountName "AWS-Report_Storage" --accessKey "AKIA3FEFCE5EFRGT" --secretKey "ILFKVXMNjZAVxc6ArAjx5wFA0C9i6F1436tr" --bucketName "reports-s3-storage" --bucketRegion "us-east-1"      


##       Use-Case 2: To Create/Update a AWS_S3 Storage Vault as defaultStorage or not for All project reports (Developer, Penetration Testing, etc.) 
       Script flow of execution: Script will create a AWS S3 storage vault if no vault account with that name exists and also to make it as default storage for all projects set flag --isDefaultStore "true". If not required either don't pass it or set flag --isDefaultStore "false".
                                 If a vault account exists with that name then it will update the vault account if it is of type ```AWS_S3``` and also make it as default storage  for all projects set flag --isDefaultStore "true". If not required either don't pass it or set flag --isDefaultStore "false".
                               
       
       Syntax:        bash apisec_s3_storage_vault.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --vaultAccountName <vault_name>         --accessKey <AWS_Access_Key>   --secretKey <AWS_Secret_Key>                       --bucketName <S3_Bucket_Name>     --bucketRegion <S_Bucket_Region> --isDefaultStore <true/false>
       Example-Usage: bash apisec_s3_storage_vault.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --vaultAccountName "AWS-Report_Storage" --accessKey "AKIA3FEFCE5EFRGT" --secretKey "ILFKVXMNjZAVxc6ArAjx5wFA0C9i6F1436tr" --bucketName "reports-s3-storage" --bucketRegion "us-east-1"       --isDefaultStore "false"


##       Use-Case 3: To Configure AWS_S3 Storage Vault for a Project.
       Script flow of execution: Script will create a AWS S3 storage vault if no vault account with that name exists and update a project with newly created AWS_S3 storage vault account.

                                 If a vault account exists with that name then it will update the vault account if it is of type ```AWS_S3``` and update a project with the pass AWS_S3 storage vault account.
       
       Syntax:        bash apisec_s3_storage_vault.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --vaultAccountName <vault_name>         --accessKey <AWS_Access_Key>   --secretKey <AWS_Secret_Key>                       --bucketName <S3_Bucket_Name>     --bucketRegion <S_Bucket_Region>  --project <Project_Name>
       Example-Usage: bash apisec_s3_storage_vault.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --vaultAccountName "AWS-Report_Storage" --accessKey "AKIA3FEFCE5EFRGT" --secretKey "ILFKVXMNjZAVxc6ArAjx5wFA0C9i6F1436tr" --bucketName "reports-s3-storage" --bucketRegion "us-east-1"        --project "NetbankingProject"

