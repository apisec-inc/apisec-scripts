# How to Run the ```apisec-python3-script.py``` for different use-cases and how script flow of execution will be with that use-case.

# Note!! Please make sure following python packages are install
   1. requests: python3 -m pip install requests
   2. pyyaml: python3 -m pip install pyyaml
   3. json: python3 -m pip install json




##       Use-Case 1: To Register/Update a Project via OpenAPISpecURL.
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and trigger a scan.
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openAPISpecUrl <OpenAPISpecURL>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openAPISpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs"



##       Use-Case 2: To Register/Update a Project via OpenAPISpec File upload.
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and trigger a scan.
                              
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openAPISpecFile   "<path-to-the-openApiSpec-json/yaml-file>"
       
       Example-Usage: wget https://raw.githubusercontent.com/apisec-inc/Netbanking-Specs/main/netbanking-spec.json -O netbanking-spec.json
                      python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openAPISpecFile   "netbanking-spec.json"      


##       Use-Case 3: To Register/Update a Project via a combination of OpenAPISpecURL and File Upload 
       Script flow of execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                                 If a project exists with that name then it will update the project and trigger a scan.
                                 Here script will  save OpenAPISpecs in a file and later use file upload method to register/update a project.
                                     
                              
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --internal_OpenAPISpecUrl <OpenAPISpecURL>                               --specType <json if specUrl have json-content OR yaml if specUrl have  yaml-content>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --internal_OpenAPISpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs" --specType "json"
       

##       Use-Case 4: To Configure a Project's Basic AuthType Credentials.
       Script flow of execution: Script will update an auth of type ```Basic``` of an exisitng environment like ```Master``` in an existing project and later trigger a scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --authName <auth Name>   --app_username <app userName>          --app_password <app password> 
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --authName "Default"     --app_username "user1@netbanking.io"   --app_password "admin@1234"

##       Use-Case 5: To Configure a Project's Token AuthType Credentials.
       Script flow of execution: Script will update an auth of type ```Token``` of an exisitng environment like ```Master``` in an existing project and later trigger a scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --authName <auth Name>   --header_1 <complete header 1 curl request to  generate token>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --authName "ROLE_PM"     --header_1 "Authorization: Bearer {{@CmdCache | curl -s -d '{"\"""username"\""":"\"""admin"\""","\"""password"\""":"\"""secret"\"""}' -H 'Content-Type: application/json' -H 'Accept: application/json' -X POST https://ip/user/login | jq --raw-output '.info.token' }}"
       
##       Use-Case 6: To Configure a Project's BaseUrl.
       Script flow of execution: Script will update ```baseUrl``` of an exisitng environment like ```Master``` in an existing project and later trigger a scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update auth creds>   --envName <existing-environmentName>   --baseUrl <baseUrl-of-the-openApiSpec>   
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                        --envName "Master"                     --baseUrl   "http://netbanking.apisec.ai:8080"

##       Use-Case 7: To Configure a Project's Profile with a scanner.
       Script flow of execution: Script will update/configure a scanner of an existing profile  like ```Master``` in an existing project and later trigger a scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --profileScanner <Scanner-Name-To-Be-Configure> --profile <Profile-Name>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --profileScanner "Super_3"                      --profile "Master" 
       
       Note!!: If no profile name is passed with this use-case then Master profile will get configured with the passed scanner.


##       Use-Case 8: To Refresh/Reload  a Project's SPecs.
       Script flow of execution: Script will Refresh/Reload of an existing project specs and later trigger a scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --refreshPlaybooks <true/false>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --refreshPlaybooks "true"

##       Use-Case 9: To Fail script execution for a Vulnerability.
       Script flow of execution: Script will trigger a scan and will fail script execution upon finding passed severity vulnerability like 'Critical'.
                                 Script will check 'Critical', 'High' and 'Medium' severities vulnerabilities.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --failOnVulnSeverity <Critical/High/Medium>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --failOnVulnSeverity "Critical"

##       Use-Case 10: To Get Triggered Scan Email Report .
       Script flow of execution: Script  trigger a scan and later send email report for the triggered scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --emailReport <true/false> --reportType <RUN_SUMMARY/RUN_DETAIL/PROJECT_SUMMARY/ PROJECT_DETAIL/PROJECT_PEN_TEST_REPORT/DEVELOPER_REPORT/COMPLIANCE>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --emailReport "true"       --reportType "RUN_SUMMARY"
       
       Note!!: If no reportType is passed with this use-case then default reportType "RUN_SUMMARY" will be send in the email report.
       
       Note!!: Scanned email report can be also be triggered with all above use-cases(1-8) by appending below parameters with them.
               No email report will come with use-cases 1,2 and 3 while registering project, but will come while updating a project.
               
               --emailReport "true" --reportType "RUN_SUMMARY"

##       Use-Case 11: To Triggered Scan on any specific category and get Email Report .
       Script flow of execution: Script  trigger a scan on a specified category like "Unsecured" and later send email report for the triggered scan.
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to update >  --emailReport <true/false> --reportType <RUN_SUMMARY/RUN_DETAIL/PROJECT_SUMMARY/ PROJECT_DETAIL/PROJECT_PEN_TEST_REPORT/DEVELOPER_REPORT/COMPLIANCE> --category <type-of-category-to-scan>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"             --emailReport "true"       --reportType "RUN_SUMMARY"               --category "Unsecured" 
       
               
##       Use-Case 12: To Triggered Scan on any specific Scanner .
       Script flow of execution: Script  trigger a scan on a specified scanner like Super_1 .
                                 
       
       Syntax:        python3 apisec-python3-script.py --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name>  --scanner <scanner_name>
       Example-Usage: python3 apisec-python3-script.py --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"  --scanner "Super_1"
