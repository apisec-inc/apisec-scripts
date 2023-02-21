# How to Run the ```apisec-script.sh``` for different use-cases and how script flow of execution will be with that use-case.

       Use-Case 1: To Register/Update a Project via OpenAPISpecURL.
       Script Flow execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                              If a project exists with that name then it will update the project and trigger a scan.
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openApiSpecUrl <OpenAPISpecURL>
       Example-Usage: bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openApiSpecUrl "http://netbanking.apisec.ai:8080/v2/api-docs"


       Use-Case 1: To Register/Update a Project via OpenAPISpec File upload.
       Script Flow execution: Script will regsiter a project if no project with that name exists and will finish there, no scanning will be trigger as auto-pilot jobs will trigger scans automatically.
                              If a project exists with that name then it will update the project and trigger a scan.
                              
       Note!!! Script requires yq tool to be installed for working with yaml files and jq tool for working with json files.
       
       Syntax:        bash apisec-script.sh --host "<host-url/IP>"                --username <apisec_username>     --password <apisec_password>   --project <project_name to register/update>   --openAPISpecFile   "<path-to-the-openApiSpec-json/yaml-file>"
       Example-Usage: wget https://raw.githubusercontent.com/apisec-inc/Netbanking-Specs/main/netbanking-spec.json -O netbanking-spec.json
                      bash apisec-script.sh --host "https://cloud.apisec.ai"      --username "admin@apisec.ai"     --password "admin@1234"        --project "netbankinapp"                      --openAPISpecFile   "netbanking-spec.json"      
