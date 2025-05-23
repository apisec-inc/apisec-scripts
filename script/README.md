# How to Run the ```apisec-script.sh``` for different use-cases and how script flow of execution will be with that use-case.

##       Use-Case 1: To Register/Update a Project via OpenAPISpecURL.
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openAPISpecUrl <OpenAPISpecURL>                                --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openAPISpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs"  --triggerScan "true"



##       Use-Case 2: To Register/Update a Project via OpenAPISpec File upload.
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
                              
       Note!!! Script requires yq tool to be installed for working with yaml files and jq tool for working with json files.
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openAPISpecFile   "<path-to-the-openApiSpec-json/yaml-file>"  --triggerScan <true/false>
       
       Example-Usage: wget https://raw.githubusercontent.com/apisec-inc/Netbanking-Specs/main/netbanking-spec.json -O netbanking-spec.json
                      bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openAPISpecFile   "netbanking-spec.json"                      --triggerScan "true"


##       Use-Case 3: To Register/Update a Project via a combination of OpenAPISpecURL and File Upload 
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false
                                 Here script will  save OpenAPISpecs in a file and later use file upload method to register/update a project.
       
       Note!!! Script requires yq tool to be installed for working with yaml files and jq tool for working with json files.                              
                              
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --internal_OpenAPISpecUrl <OpenAPISpecURL>                               --specType <json if specUrl have json-content OR yaml if specUrl have  yaml-content>  --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --internal_OpenAPISpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs" --specType "json"                                                                     --triggerScan "true"
       

##       Use-Case 4: To Configure a Project's Basic AuthType Credentials.
       Script flow of execution: Script will update an auth of type ```Basic``` of an exisitng environment like ```Master``` in an existing project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --authName <auth Name>   --app_username <app userName>          --app_password <app password>  --triggerScan <true/false> 
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --authName "Default"     --app_username "user1@netbanking.io"   --app_password "admin@1234"    --triggerScan "true"

##       Use-Case 5: To Configure a Project's Token AuthType Credentials.
       Script flow of execution: Script will update an auth of type ```Token``` of an exisitng environment like ```Master``` in an existing project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --authName <auth Name>   --header_1 <complete header 1 curl request to  generate token>                                                                                                                                                                                                             --triggerScan <true/false> 
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --authName "ROLE_PM"     --header_1 "Authorization: Bearer {{@CmdCache | curl -s -d '{"\"""username"\""":"\"""admin"\""","\"""password"\""":"\"""secret"\"""}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST https://ip/user/login | jq --raw-output '.info.token' }}"  --triggerScan "true"
       
##       Use-Case 6: To Configure a Project's BaseUrl.
       Script flow of execution: Script will update ```baseUrl``` of an exisitng environment like ```Master``` in an existing project and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --baseUrl <baseUrl-of-the-openApiSpec>          --triggerScan <true/false>   
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --baseUrl   "http://netbanking.apisec.ai:8080"  --triggerScan "true"

##       Use-Case 7: To Configure a Project's Profile for following profile use-cases.
       Use-Case 7a. To Configure a Project's Profile with a scanner and categories and aslo  will trigger a scan on Passed profile depending upon whether value  with --triggerScan flag is true or false
       Script flow of execution: Script will update/configure a scanner and categories of an existing profile  like ```Master``` in an existing project.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --profileScanner <Scanner-Name-To-Be-Configure>  --profileCategories "<Comma Separated Category Names>"               --profile <Profile-Name>  --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --profileScanner "Super_3"                       --profileCategories "Unsecured,ABAC_Level1,Linux_Command_Injection"  --profile "Master"        --triggerScan "true"
       
      


       Use-Case 7b. To Configure a Project's Profile with a scanner
       Script flow of execution: Script will update/configure a scanner of an existing profile  like ```Master``` in an existing project and will trigger a scan on passed profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --profileScanner <Scanner-Name-To-Be-Configure> --profile <Profile-Name>  --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --profileScanner "Super_3"                      --profile "Master"        --triggerScan "true"
       
       


       Use-Case 7c. To Configure a Project's Profile with  categories
       Script flow of execution: Script will update/configure a categories of an existing profile  like ```Master``` in an existing project and will trigger a scan on passed profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --profileCategories "<Comma Separated Category Names>"               --profile <Profile-Name>   --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --profileCategories "Unsecured,ABAC_Level1,Linux_Command_Injection"  --profile "Master"         --triggerScan "true"
       
       Note!!: If no profile name is passed with these use-cases then Master profile will get configured.       

##       Use-Case 8: To Refresh/Reload  a Project's SPecs.
       Script flow of execution: Script will Refresh/Reload of an existing project specs and will trigger a scan on Master profile depending upon whether value  with --triggerScan flag is true or false.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --refresh-playbooks <true/false>  --triggerScan <true/false>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --refresh-playbooks "true"        --triggerScan "true"

##       Use-Case 9: To Fail script execution for a Vulnerability.
       Script flow of execution: Script will trigger a scan on Master profile and will fail script execution upon finding passed severity vulnerability like 'Critical'.
                                 Script will check 'Critical', 'High' and 'Medium' severities vulnerabilities.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --fail-on-vuln-severity <Critical/High/Medium>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --fail-on-vuln-severity "Critical"

##       Use-Case 10: To Get Triggered Scan Email Report.
       Script flow of execution: Script will trigger a scan on Master profile and later send email report for the triggered scan.
                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --emailReport <true/false> --reportType <RUN_SUMMARY/RUN_DETAIL/PROJECT_SUMMARY/ PROJECT_DETAIL/PROJECT_PEN_TEST_REPORT/DEVELOPER_REPORT/COMPLIANCE>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --emailReport "true"       --reportType "RUN_SUMMARY"
       
       Note!!: If no reportType is passed with this use-case then default reportType "RUN_SUMMARY" will be send in the email report.
       
       Note!!: Scanned email report can be also be triggered with all above use-cases(1-8) by appending below parameters with them.
               No email report will come with use-cases 1,2 and 3 while registering project, but will come while updating a project.
               
               --emailReport "true" --reportType "RUN_SUMMARY"

##       Use-Case 11: To Triggered Scan on for following Use-Cases.
       Use-Case 11-a: To Triggered Scan on any specific profile
       Script flow of execution: Script will trigger a scan on  categories of passed profile.                                  
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --profile <Profile-Name>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --profile "Master"


       Use-Case 11-b: To Triggered Scan on any specific scanner
       Script flow of execution: Script will trigger a scan on  categories of a Master profile on passed scanner name.                                  
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --scanner <scanner_name>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --scanner "Super_1

       Use-Case 11-c: To Triggered Scan on any specific category
       Script flow of execution: Script will trigger a scan on a specified category like "Unsecured" on Master profile.                                 
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --category <type-of-category-to-scan>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --category "Unsecured" 
       

       
       
       Note!!: Scanned email report can be also be triggered with all above 11 sub use-cases(a-c) by appending below parameters with them.
                              
               --emailReport "true" --reportType "RUN_SUMMARY"
               
       Note!!: reportType Valid values are: RUN_SUMMARY/RUN_DETAIL/PROJECT_SUMMARY/ PROJECT_DETAIL/PROJECT_PEN_TEST_REPORT/DEVELOPER_REPORT/COMPLIANCE
       
       Note!!: If no reportType is passed with these use-cases then default reportType "RUN_SUMMARY" will be send in the email report.
               
