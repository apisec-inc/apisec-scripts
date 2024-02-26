# How to Run the ```apisec-private-scanner-docker.sh``` in Docker Installed Linux/MacOS VMs.

##       Use-Case 1: To Deploy Regular Scanner.       
       Syntax:        bash apisec-private-scanner-docker.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>   
       Example-Usage: bash apisec-private-scanner-docker.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    



##       Use-Case 2: To Deploy A Scanner With Specific ConcurrentConusumers.       
       Syntax:        bash apisec-private-scanner-docker.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>                                                   --concurrentConsumers <Integer-Number>   --maxConcurrentConsumers  <Integer-Number>
       Example-Usage: bash apisec-private-scanner-docker.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow==" --concurrentConsumers "5"                --maxConcurrentConsumers  "5"   



##       Use-Case 3:  To Deploy A Rate-Limiting Scanner.       
       Syntax:        bash apisec-private-scanner-docker.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>                                                   --concurrentConsumers <Integer-Number>   --maxConcurrentConsumers  <Integer-Number>  --delay <Integer-Number>
       Example-Usage: bash apisec-private-scanner-docker.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow==" --concurrentConsumers "5"                --maxConcurrentConsumers  "5"               --delay "5000"





# How to Run the ```apisec-private-scanner-k8s.sh``` in  On-Prem/Managed Kubernetes Cluster.

##       Use-Case 1: To Deploy Regular Scanner.       
       Syntax:        bash apisec-private-scanner-k8s.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>   
       Example-Usage: bash apisec-private-scanner-k8s.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    



##       Use-Case 2: To Deploy A Scanner With Specific ConcurrentConusumers.       
       Syntax:        bash apisec-private-scanner-k8s.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>                                                   --concurrentConsumers <Integer-Number>   --maxConcurrentConsumers  <Integer-Number>
       Example-Usage: bash apisec-private-scanner-k8s.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow==" --concurrentConsumers "5"                --maxConcurrentConsumers  "5"   



##       Use-Case 3:  To Deploy A Rate-Limiting Scanner.       
       Syntax:        bash apisec-private-scanner-k8s.sh --host "<hostname/IP>"    --scannerName <scannerName>    --fx-iam <FX_IAM>                            --fx-key <FX_KEY>                                                   --concurrentConsumers <Integer-Number>   --maxConcurrentConsumers  <Integer-Number>  --delay <Integer-Number>
       Example-Usage: bash apisec-private-scanner-k8s.sh --host "cloud.apisec.ai"  --scannerName apisec-demo      --fx-iam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  --fx-key "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow==" --concurrentConsumers "5"                --maxConcurrentConsumers  "5"               --delay "5000"       

# How to Run the ```apisec-private-scanner-docker-windows.ps``` in Docker Installed Windows VMs.

##       Use-Case 1: To Deploy Regular Scanner.       
       Syntax:        powershell -File apisec-private-scanner-docker-windows.ps -host  <hostname/IP>    -scannerName <scannerName>    -fxIam <FX_IAM>                            -fxKey <FX_KEY>   
       Example-Usage: powershell -File apisec-private-scanner-docker-windows.ps -host "cloud.apisec.ai" -scannerName "apisec-demo"    -fxIam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  -fxKey "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="    



##       Use-Case 2: To Deploy A Scanner With Specific ConcurrentConusumers.       
       Syntax:        powershell -File apisec-private-scanner-docker-windows.ps -host <hostname/IP>     -scannerName <scannerName>    -fxIam <FX_IAM>                            -fxKey <FX_KEY>                                                     -concurrentConsumers <Integer-Number>   -maxConcurrentConsumers  <Integer-Number>
       Example-Usage: powershell -File apisec-private-scanner-docker-windows.ps -host "cloud.apisec.ai" -scannerName "apisec-demo"    -fxIam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  -fxKey "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="  -concurrentConsumers "5"                -maxConcurrentConsumers  "5"   



##       Use-Case 3:  To Deploy A Rate-Limiting Scanner.       
       Syntax:        powershell -File apisec-private-scanner-docker-windows.ps -host <hostname/IP>     -scannerName <scannerName>    -fxIam <FX_IAM>                            -fxKey <FX_KEY>                                                     -concurrentConsumers <Integer-Number>   -maxConcurrentConsumers  <Integer-Number> -delay <Integer-Number>
       Example-Usage: powershell -File apisec-private-scanner-docker-windows.ps -host "cloud.apisec.ai" -scannerName "apisec-demo"    -fxIam "wzQosLb96KtdxfRjbl6jMGFpWEYYajgd"  -fxKey "cNc4bKuaXCH9/8l1nYSgPYYRIWmN9vX+3f/zsea6VfSBsbDbrPJVow=="   -concurrentConsumers "5"                -maxConcurrentConsumers  "5"              -delay "5000"