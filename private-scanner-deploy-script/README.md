# How to Deploy APIsec Scanner in Customer's On-Prem Environments

##     How to Run the ```apisec-private-scanner-docker.sh``` in Docker Installed Linux/MacOS VMs.   
       Script flow of execution: Run the script as shown in below syntax replacing relevant Key-Value pairs with your specific scanner ones.
                                 Once you run the script, it will prompt user with below options, pick one based on your requirements.
                                 Any other enter argument/value will result in you having to re-run the script again.

                                       "Press '1' to Deploy  APIsec Scanner!!"
                                       "Press '2' to Restart APIsec Scanner!!"
                                       "Press '3' to Refresh APIsec Scanner!!"
                                                          
                             
       Syntax:        bash apisec-private-scanner-docker.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>   
       Example-Usage: bash apisec-private-scanner-docker.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    




##     How to Run the ```apisec-private-scanner-k8s.sh``` in  On-Prem/Managed Kubernetes Cluster.   
       Script flow of execution: Run the script as shown in below syntax replacing relevant Key-Value pairs with your specific scanner ones.
                                 Once you run the script, it will prompt user with below options, pick one based on your requirements.
                                 Any other enter argument/value will result in you having to re-run the script again.

                                       "Press '1' to Deploy  APIsec Scanner!!"
                                       "Press '2' to Restart APIsec Scanner!!"
                                       "Press '3' to Refresh APIsec Scanner!!"
                                                          

       Syntax:        bash apisec-private-scanner-k8s.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>   
       Example-Usage: bash apisec-private-scanner-k8s.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    



##      How to Run the ```apisec-private-scanner-docker.ps1``` in Docker Installed Windows VMs.
       Script flow of execution: Run the script as shown in below syntax replacing relevant Key-Value pairs with your specific scanner ones.
                                 Once you run the script, it will prompt user with below options, pick one based on your requirements.
                                 Any other enter argument/value will result in you having to re-run the script again.

                                       "Press '1' to Deploy  APIsec Scanner!!"
                                       "Press '2' to Restart APIsec Scanner!!"
                                       "Press '3' to Refresh APIsec Scanner!!"
                                                          

       Syntax:        powershell -File apisec-private-scanner-docker.ps1 -host  <hostname/IP>    -scannerName <scannerName>    -fxIam <FX_IAM>                            -fxKey <FX_KEY>   
       Example-Usage: powershell -File apisec-private-scanner-docker.ps1 -host "cloud.apisec.ai" -scannerName "apisec-demo"    -fxIam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  -fxKey "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    



