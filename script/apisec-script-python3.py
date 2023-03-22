import requests
import json
import argparse
import time
import os
import yaml

# Initiate the parser
parser = argparse.ArgumentParser()

# Add long and short argument
parser.add_argument("--host", help="hostUrl")
parser.add_argument("--username", help="username")
parser.add_argument("--password", help="pasword")
parser.add_argument("--project", help="project name")
parser.add_argument("--profile", help="profile name")
parser.add_argument("--scanner", help="scanner name")
parser.add_argument("--outputfile", help="output filename")
parser.add_argument("--emailReport", help="Send email report true/false")
parser.add_argument("--reportType", help="Email report Type")
parser.add_argument("--failOnVulnSeverity", help="Vulnerable Severity to fail")
parser.add_argument("--refreshPlaybooks", help="Reload Playbooks")


parser.add_argument("--openAPISpecUrl", help="Open API Spec URL")
parser.add_argument("--openAPISpecFile", help="Open API Spec File")
parser.add_argument("--internal_OpenAPISpecUrl", help="Open API Spec Url")
parser.add_argument("--specType", help="Open API Spec Type")
parser.add_argument("--profileScanner", help="Scanner Name to be configured with the profile")
parser.add_argument("--envName", help="Environment Name")
parser.add_argument("--authName", help="Auth Name")

parser.add_argument("--app_username", help="application user's name")
parser.add_argument("--app_password", help="application user's password")
parser.add_argument("--app_endPointUrl", help="application token endpoint")
parser.add_argument("--app_token_param", help="application token param")

parser.add_argument("--baseUrl", help="BaseUrl of App")
parser.add_argument("--category", help="Category's Name to run a scan")
parser.add_argument("--tier", help="Profile Tier Type")
parser.add_argument("--tags", help="Tags")




# Read arguments from the command line
args = parser.parse_args()
FX_HOST=args.host
FX_USER=args.username
FX_PASS=args.password
FX_PROJECT_NAME=args.project
PROFILE_NAME=args.profile
REGION=args.scanner
OUTPUT_FILENAME=args.outputfile
FX_EMAIL_REPORT=args.emailReport
FX_REPORT_TYPE=args.reportType
FAIL_ON_VULN_SEVERITY=args.failOnVulnSeverity
REFRESH_PLAYBOOKS=args.refreshPlaybooks
OPEN_API_SPEC_URL=args.openAPISpecUrl
OPEN_API_SPEC_FILE=args.openAPISpecFile
INTERNAL_OPEN_API_SPEC=args.internal_OpenAPISpecUrl
SPEC_TYPE=args.specType
PROFILE_SCANNER=args.profileScanner
ENV_NAME=args.envName
AUTH_NAME=args.authName
APP_USER=args.app_username
APP_PWD=args.app_password
ENDPOINT_URL=args.app_endPointUrl
TOKEN_PARAM=args.app_token_param
BASE_URL=args.baseUrl
CAT=args.category
TIER=args.tier
FX_TAGS=args.tags
FX_SCRIPT=""


if FX_PROJECT_NAME != None or FX_PROJECT_NAME == "":
    a=FX_PROJECT_NAME
    a = a.replace('`', ' ') ;a = a.replace('~', ' ') ;a = a.replace('!',' ')  ;a = a.replace('@', ' ') ;a = a.replace('#', ' ') ;a = a.replace('$', ' ') ;a = a.replace('%', ' ') ;a = a.replace('^', ' ') ;a = a.replace('&', ' ') ;a = a.replace('*', ' ') ;a = a.replace('(', ' ') ;a = a.replace(')', ' ') ;a = a.replace('-', ' ') ;a = a.replace('=', ' ') ;a = a.replace('+', ' ') ;a = a.replace('{', ' ') ;a = a.replace('}', ' ') ;a = a.replace('[', ' ') ;a = a.replace(']', ' ') ;a = a.replace(';', ' ') ;a = a.replace(':', ' ') ;a = a.replace('"', ' ') ;a = a.replace("'", ' ') ;a = a.replace('|', ' ') ;a = a.replace('<', ' ') ;a = a.replace('>', ' ') ;a = a.replace(',', ' ') ;a = a.replace('.', ' ') ;a = a.replace('/', ' ') ;a = a.replace('?', ' ')
    FX_PROJECT_NAME=a
    PROJECT_NAME=FX_PROJECT_NAME.replace(' ', '%20')

payload = json.dumps({
  "username": f"{FX_USER}",
  "password": f"{FX_PASS}"
})
headers = {
  'Content-Type': 'application/json'
}

response = requests.request("POST", f'{FX_HOST}/login', headers=headers, data=payload)
token = response.json()['token']
print("")
print(token)
tokenheaders = {
  'Content-Type': 'application/json',
  'accept': '*/*',
  'Authorization': f'Bearer {token}'
}

if FX_HOST == "" or FX_HOST == None:
    FX_HOST="https://cloud.apisec.ai"

if REGION == "" or REGION == None:
    REGION="Super_3"
if FX_EMAIL_REPORT == "" or FX_EMAIL_REPORT == None:
    FX_EMAIL_REPORT="false"

if FX_REPORT_TYPE == "" or FX_REPORT_TYPE == None:
    FX_REPORT_TYPE=""    

if PROFILE_NAME == "" or PROFILE_NAME == None:
    PROFILE_NAME="Master"

if FAIL_ON_VULN_SEVERITY == "Critical"  or FAIL_ON_VULN_SEVERITY == "High"  or FAIL_ON_VULN_SEVERITY == "Medium":
    FAIL_ON_VULN_SEVERITY_FLAG=True
else:
    FAIL_ON_VULN_SEVERITY_FLAG=False        


if OPEN_API_SPEC_URL == "" or OPEN_API_SPEC_URL == None:
     OPEN_API_SPEC_URL_FLAG=False     
else:
     OPEN_API_SPEC_URL_FLAG=True
     
if OPEN_API_SPEC_FILE == "" or OPEN_API_SPEC_FILE == None:
     OPEN_API_SPEC_FILE_FLAG=False     
else:
     OPEN_API_SPEC_FILE_FLAG=True

if INTERNAL_OPEN_API_SPEC == "" or INTERNAL_OPEN_API_SPEC == None:
     INTERNAL_OPEN_API_SPEC_FLAG=False     
else:
     INTERNAL_OPEN_API_SPEC_FLAG=True

if REFRESH_PLAYBOOKS == "" or REFRESH_PLAYBOOKS == None:
    REFRESH_PLAYBOOKS=False
elif REFRESH_PLAYBOOKS == "true" or REFRESH_PLAYBOOKS == "True":
    REFRESH_PLAYBOOKS=True


if PROFILE_SCANNER == "" or PROFILE_SCANNER == None:
    PROFILE_SCANNER_FLAG=False
else:
    PROFILE_SCANNER_FLAG=True
    SCANNER_NAME=f'{PROFILE_SCANNER}'
    PROFILE_NAME=f"{PROFILE_NAME}"

if AUTH_NAME == "" or AUTH_NAME == None:
     AUTH_NAME_FLAG=False     
else:
     AUTH_NAME_FLAG=True

if TOKEN_PARAM == "" or TOKEN_PARAM == None:
    TOKEN_PARAM=".info.token"

if BASE_URL == "" or BASE_URL == None:
     BASE_URL_FLAG=False     
else:
     BASE_URL_FLAG=True

if CAT == "" or CAT == None:
    CAT=""

if OPEN_API_SPEC_URL_FLAG == True:
    response = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=response.json()['errors']
    if errors == True:
         message=response.json()['messages'][0]['value']      
         print(message)
         print(f"Registering Project  '{FX_PROJECT_NAME}'  via OpenAPISpecUrl method!!")
         payload = json.dumps({
             "name": f"{FX_PROJECT_NAME}",
             "openAPISpec": f"{OPEN_API_SPEC_URL}",
             "planType": "ENTERPRISE",
             "isFileLoad": False,
             "source": "API",
             "personalizedCoverage": {
                 "auths": []
                 }
         })
         resp = requests.request("POST", f"{FX_HOST}/api/v1/projects", headers=tokenheaders, data=payload)
         perrors = resp.json()['errors']
         if perrors == True:
             pMessage=resp.json()['messages'][0]['value']
             print(pMessage)
             exit(1)
             print("Hello testing")
         elif perrors == False:
             projectId = resp.json()['data']['id']
             projectName = resp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks generate task Status....")

                 pCount += 1                
                 retryCount += 1
                 time.sleep(10)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']                 
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Playbooks generation task for the registered project '{FX_PROJECT_NAME}' is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")
                     print(f'Script Execution is Done.')
                     exit(0)

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)

    elif errors == False:
        print (f"Updating Project  {FX_PROJECT_NAME} via OpenAPISpecUrl method!!")
        projectName = response.json()['data']['name']
        projectId = response.json()['data']['id']
        orgId=response.json()['data']['org']['id']  
        payload = json.dumps({
            "id": f"{projectId}",
            "org": {
                "id": f"{orgId}"
                },
            "name": f"{FX_PROJECT_NAME}",
            "openAPISpec": f"{OPEN_API_SPEC_URL}",
            "openText": "",
            "isFileLoad": False
        })
        updateresp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/refresh-specs", headers=tokenheaders, data=payload)
        uerrors = updateresp.json()['errors']
        if uerrors == True:
             uMessage=updateresp.json()['messages'][0]['value']
             print(uMessage)
             exit(1)             
        elif uerrors == False:
             projectId = updateresp.json()['data']['id']
             projectName = updateresp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks regenerate task Status....")

                 pCount += 1                 
                 retryCount += 1
                 time.sleep(2)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Project update via OpenAPISpecUrl and playbooks refresh task is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)

if OPEN_API_SPEC_FILE_FLAG == True:
    fileExt=OPEN_API_SPEC_FILE
    if "json" in fileExt:
        print("Json File Upload Option is used")        
        f = open(f'{OPEN_API_SPEC_FILE}')
        data = json.load(f)    
        f.close()
        openText=json.dumps(data)
    elif "yaml" in fileExt or "yml" in fileExt:
        print("Yaml File Upload Option is used")
        with open(f'{OPEN_API_SPEC_FILE}', 'r') as file:
            configuration = yaml.safe_load(file)
        openText=yaml.dump(configuration)    

    response = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=response.json()['errors']
    if errors == True:
         message=response.json()['messages'][0]['value']      
         print(message)
         print(f"Registering Project  '{FX_PROJECT_NAME}'  via OpenAPISpecFile method!!")

         payload = json.dumps({
             "name": f"{FX_PROJECT_NAME}",
             "openAPISpec": "none",
             "planType": "ENTERPRISE",
             "isFileLoad": "true",
             "openText": f"{openText}",
             "source": "API",
             "personalizedCoverage": {
                 "auths": []
                 }
         })
         resp = requests.request("POST", f"{FX_HOST}/api/v1/projects", headers=tokenheaders, data=payload)
         perrors = resp.json()['errors']
         if perrors == True:
             pMessage=resp.json()['messages'][0]['value']
             print(pMessage)
             exit(1)
             print("Hello testing")
         elif perrors == False:
             projectId = resp.json()['data']['id']
             projectName = resp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks generate task Status....")

                 pCount += 1                 
                 retryCount += 1
                 time.sleep(10)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']                 
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Playbooks generation task for the registered project '{FX_PROJECT_NAME}' is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")
                     print(f'Script Execution is Done.')
                     exit(0)

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)    

    elif errors == False:
        print (f"Updating Project  {FX_PROJECT_NAME} via OpenAPISpecFile method!!")
        projectName = response.json()['data']['name']
        projectId = response.json()['data']['id']
        orgId=response.json()['data']['org']['id']  
        payload = json.dumps({
            "id": f"{projectId}",
            "org": {
                "id": f"{orgId}"
                },
            "name": f"{FX_PROJECT_NAME}",
            "openAPISpec": "none",
            "isFileLoad": "true",
            "openText": f"{openText}",
            "source": "API"            
        })
        updateresp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/refresh-specs", headers=tokenheaders, data=payload)
        uerrors = updateresp.json()['errors']
        if uerrors == True:
             uMessage=updateresp.json()['messages'][0]['value']
             print(uMessage)
             exit(1)             
        elif uerrors == False:
             projectId = updateresp.json()['data']['id']
             projectName = updateresp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks regenerate task Status....")

                 pCount += 1                 
                 retryCount += 1
                 time.sleep(2)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Project update via OpenAPISpecFile and playbooks refresh task is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)

if INTERNAL_OPEN_API_SPEC_FLAG == True:
    fileExt=SPEC_TYPE
    if "json" in fileExt:
        print("Json File Upload Option is used")
        jsonResp = requests.request("GET", f"{INTERNAL_OPEN_API_SPEC}", headers=headers)
        jsonString = json.dumps(jsonResp.json())
        jsonFile = open("open-api-spec-file.json", "w")
        jsonFile.write(jsonString)
        jsonFile.close()

        f = open('open-api-spec-file.json')
        data = json.load(f)    
        f.close()
        openText=json.dumps(data)
        os.remove("open-api-spec-file.json")

    elif "yaml" in fileExt or "yml" in fileExt:
        print("Yaml File Upload Option is used")
        yamlResp = requests.request("GET", f"{INTERNAL_OPEN_API_SPEC}", headers=headers)
        yamlData = yaml.dump(yamlResp)

        # with open('Netcracker2.yaml', 'r') as file:
        #     configuration = yaml.safe_load(file)
        # yamlData=yaml.dump(configuration)

        data = yaml.safe_load(yamlData)
        
        with open('open-api-spec-file.yaml', 'w') as file:
            yaml.dump(data, file)

        with open('open-api-spec-file.yaml', 'r') as file:
            configuration = yaml.safe_load(file)
        openText=yaml.dump(configuration)
        os.remove("open-api-spec-file.yaml") 

    response = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=response.json()['errors']
    if errors == True:
         message=response.json()['messages'][0]['value']      
         print(message)
         print(f"Registering Project  '{FX_PROJECT_NAME}'  via OpenAPISpecFile method!!")

         payload = json.dumps({
             "name": f"{FX_PROJECT_NAME}",
             "openAPISpec": "none",
             "planType": "ENTERPRISE",
             "isFileLoad": "true",
             "openText": f"{openText}",
             "source": "API",
             "personalizedCoverage": {
                 "auths": []
                 }
         })
         resp = requests.request("POST", f"{FX_HOST}/api/v1/projects", headers=tokenheaders, data=payload)
         perrors = resp.json()['errors']
         if perrors == True:
             pMessage=resp.json()['messages'][0]['value']
             print(pMessage)
             exit(1)
             print("Hello testing")
         elif perrors == False:
             projectId = resp.json()['data']['id']
             projectName = resp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks generate task Status....")

                 pCount += 1                 
                 retryCount += 1
                 time.sleep(10)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']                 
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Playbooks generation task for the registered project '{FX_PROJECT_NAME}' is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")
                     print(f'Script Execution is Done.')
                     exit(0)

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)    

    elif errors == False:
        print (f"Updating Project  {FX_PROJECT_NAME} via OpenAPISpecFile method!!")
        projectName = response.json()['data']['name']
        projectId = response.json()['data']['id']
        orgId=response.json()['data']['org']['id']  
        payload = json.dumps({
            "id": f"{projectId}",
            "org": {
                "id": f"{orgId}"
                },
            "name": f"{FX_PROJECT_NAME}",
            "openAPISpec": "none",
            "isFileLoad": "true",
            "openText": f"{openText}",
            "source": "API"            
        })
        updateresp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/refresh-specs", headers=tokenheaders, data=payload)
        uerrors = updateresp.json()['errors']
        if uerrors == True:
             uMessage=updateresp.json()['messages'][0]['value']
             print(uMessage)
             exit(1)             
        elif uerrors == False:
             projectId = updateresp.json()['data']['id']
             projectName = updateresp.json()['data']['name']
             playbookTaskStatus="In_progress"
             print(f"playbookTaskStatus =  {playbookTaskStatus}")
             retryCount=0
             pCount=0
             while playbookTaskStatus == "In_progress":
                 if pCount == 0:
                     print ("Checking playbooks regenerate task Status....")

                 pCount += 1                 
                 retryCount += 1
                 time.sleep(2)

                 taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
                 playbookTaskStatus = taskResp.json()['data']['status']
                 if playbookTaskStatus == "Done":
                     print(" ")
                     print(f"Project update via OpenAPISpecFile and playbooks refresh task is succesfully completed!!!")
                     print(f"ProjectName: '{projectName}'")
                     print(f"ProjectId: {projectId}")

                 if retryCount > 55:
                     print(" ")    
                     retryCount *= 2
                     print(f"Playbooks Generation Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                     exit(1)

if REFRESH_PLAYBOOKS == True:
    refreshResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=refreshResp.json()['errors']
    if errors == True:
        message=response.json()['messages'][0]['value']      
        print(message)
    elif errors == False:
        projectId = refreshResp.json()['data']['id']
        projectName = refreshResp.json()['data']['name']
        dto = refreshResp.json()['data']
        payload = f"{dto}"
        refreshPlaybooksResp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/refresh-specs", headers=tokenheaders, data=payload)
        playbookTaskStatus="In_progress"
        print(f"playbookTaskStatus =  {playbookTaskStatus}")
        retryCount=0
        pCount=0
        while playbookTaskStatus == "In_progress":
            if pCount == 0:
                print ("Checking playbooks regenerate task Status....")
            
            pCount += 1                 
            retryCount += 1
            time.sleep(2)
            
            taskResp = requests.request("GET", f"{FX_HOST}/api/v1/events/project/{projectId}/Sync", headers=tokenheaders)
            playbookTaskStatus = taskResp.json()['data']['status']
            if playbookTaskStatus == "Done":
                print(" ")
                print(f"Playbooks refresh task is succesfully completed!!!")
                print(f"ProjectName: '{projectName}'")
                print(f"ProjectId: {projectId}")

            if retryCount > 55:
                print(" ")    
                retryCount *= 2
                print(f"Playbooks Refresh Task Status: {playbookTaskStatus} even after {retryCount} seconds, so halting/breaking script execution!!!")
                exit(1)

if PROFILE_SCANNER_FLAG == True:
    refreshResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=refreshResp.json()['errors']
    if errors == True:
        message=response.json()['messages'][0]['value']      
        print(message)
    elif errors == False:
        projectId = refreshResp.json()['data']['id']
        projectName = refreshResp.json()['data']['name']
        dto = refreshResp.json()['data']
        dataResp = requests.request("GET", f"{FX_HOST}/api/v1/jobs/project-id/{projectId}?page=0&pageSize=20&sort=modifiedDate%2CcreatedDate&sortType=DESC", headers=tokenheaders)
        test=dataResp.json()['data']
        test=json.dumps(test)
        json_object = json.loads(test)
        for element in json_object:
            profName=element['name']
            profId=element['id']
            if PROFILE_NAME == profName:                
                print(f"Updating $PROFILE_NAME profile with {SCANNER_NAME} scanner in {FX_PROJECT_NAME} project!!")
                element["regions"] = SCANNER_NAME
                udto=json.dumps(element)
                payload = f"{udto}"
                updateResp = requests.request("PUT", f"{FX_HOST}/api/v1/jobs", headers=tokenheaders, data=payload)
                updatedScanner = updateResp.json()['data']['regions']
                print(" ")
                print(f"ProjectName: {FX_PROJECT_NAME}")
                print(f"ProjectId: {projectId}")
                print(f"ProfileName: {PROFILE_NAME}")
                print(f"ProfileId: {profId}")
                print(f"UpdatedScannerName: {updatedScanner}")
                print(" ")                          

if AUTH_NAME_FLAG == True:
    authResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=authResp.json()['errors']
    if errors == True:
        message=authResp.json()['messages'][0]['value']      
        print(message)
    elif errors == False:
        projectId = authResp.json()['data']['id']
        projectName = authResp.json()['data']['name']
        dto = authResp.json()['data']
        dataResp = requests.request("GET", f"{FX_HOST}/api/v1/envs/projects/{projectId}?page=0&pageSize=25", headers=tokenheaders)
        test=dataResp.json()['data']
        test=json.dumps(test)
        json_object = json.loads(test)
        for element in json_object:
            envName=element['name']
            envId=element['id']
            if ENV_NAME == envName:
                updatedAuths = element['auths']
                updatedAuths1 = element['auths']                
                for auth in updatedAuths:
                    authName=auth['name']
                    authType=auth['authType']
                    if authType == "Basic":
                        if AUTH_NAME == authName:
                            print (f"Updating '{AUTH_NAME}' Auth with Basic as AuthType of '{ENV_NAME}' environment in '{FX_PROJECT_NAME}' project!!")
                            print(" ")
                            auth['username'] = APP_USER
                            auth['password'] = APP_PWD
                            modifiedAuths = [auth if d['name'] == f'{AUTH_NAME}' else d for d in updatedAuths1]
                            element['auths'] = modifiedAuths
                            udto = json.dumps(element)
                            payload = f"{udto}"
                            authUpdateResp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/env/{envId}", headers=tokenheaders, data=payload)
                            authData = authUpdateResp.json()['data']['auths']
                            for uAuth in authData:
                                upAuthName = uAuth['name']
                                if AUTH_NAME == upAuthName:
                                    updatedAuthObj = uAuth
                                    print(" ")
                                    print(f"ProjectName: {FX_PROJECT_NAME}")
                                    print(f"ProjectId: {projectId}")
                                    print(f"EnvironmentName: {ENV_NAME}")
                                    print(f"EnvironmentId: {envId}")
                                    print(f"UpdatedAuth: {updatedAuthObj}")
                                    print(" ")

                    elif authType == "Digest":
                        if AUTH_NAME == authName:
                            print (f"Updating '{AUTH_NAME}' Auth with Digest as AuthType of '{ENV_NAME}' environment in '{FX_PROJECT_NAME}' project!!")
                            print(" ")
                            auth['username'] = APP_USER
                            auth['password'] = APP_PWD
                            modifiedAuths = [auth if d['name'] == f'{AUTH_NAME}' else d for d in updatedAuths1]
                            element['auths'] = modifiedAuths
                            udto = json.dumps(element)
                            payload = f"{udto}"
                            authUpdateResp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/env/{envId}", headers=tokenheaders, data=payload)
                            authData = authUpdateResp.json()['data']['auths']
                            for uAuth in authData:
                                upAuthName = uAuth['name']
                                if AUTH_NAME == upAuthName:
                                    updatedAuthObj = uAuth
                                    print(" ")
                                    print(f"ProjectName: {FX_PROJECT_NAME}")
                                    print(f"ProjectId: {projectId}")
                                    print(f"EnvironmentName: {ENV_NAME}")
                                    print(f"EnvironmentId: {envId}")
                                    print(f"UpdatedAuth: {updatedAuthObj}")
                                    print(" ")

                    elif authType == "Token":
                        if AUTH_NAME == authName:
                            print (f"Updating '{AUTH_NAME}' Auth with Token as AuthType of '{ENV_NAME}' environment in '{FX_PROJECT_NAME}' project!!")                          
                            mAuth=f"Authorization: Bearer {{{{@CmdCache | curl -s -d '{{\"username\":\"{APP_USER}\",\"password\":\"{APP_PWD}\"}}' -H \"Content-Type: application/json\" -H \"Accept: application/json\" -X POST \"{ENDPOINT_URL}\" | jq --raw-output \"{TOKEN_PARAM}\" }}}}"
                            auth['header_1'] = mAuth                            
                            modifiedAuths = [auth if d['name'] == f'{AUTH_NAME}' else d for d in updatedAuths1]
                            element['auths'] = modifiedAuths
                            udto = json.dumps(element)
                            payload = f"{udto}"
                            authUpdateResp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/env/{envId}", headers=tokenheaders, data=payload)
                            authData = authUpdateResp.json()['data']['auths']
                            for uAuth in authData:
                                upAuthName = uAuth['name']
                                if AUTH_NAME == upAuthName:
                                    updatedAuthObj = uAuth
                                    print(" ")
                                    print(f"ProjectName: {FX_PROJECT_NAME}")
                                    print(f"ProjectId: {projectId}")
                                    print(f"EnvironmentName: {ENV_NAME}")
                                    print(f"EnvironmentId: {envId}")
                                    print(f"UpdatedAuth: {updatedAuthObj}")
                                    print(" ")
                            
if BASE_URL_FLAG == True:
    baseResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
    errors=baseResp.json()['errors']
    if errors == True:
        message=baseResp.json()['messages'][0]['value']      
        print(message)
    elif errors == False:
        projectId = baseResp.json()['data']['id']
        projectName = baseResp.json()['data']['name']
        dto = baseResp.json()['data']
        dataResp = requests.request("GET", f"{FX_HOST}/api/v1/envs/projects/{projectId}?page=0&pageSize=25", headers=tokenheaders)
        test=dataResp.json()['data']
        test=json.dumps(test)
        json_object = json.loads(test)
        for element in json_object:
            envName=element['name']
            envId=element['id']
            if ENV_NAME == envName:                
                print(f"Updating '{ENV_NAME}' environment with '{BASE_URL}' as baseUrl in '{FX_PROJECT_NAME}' project!!")
                element["baseUrl"] = BASE_URL
                udto=json.dumps(element)
                payload = f"{udto}"
                updateResp = requests.request("PUT", f"{FX_HOST}/api/v1/projects/{projectId}/env/{envId}", headers=tokenheaders, data=payload)
                UpdatedBaseUrl = updateResp.json()['data']['baseUrl']
                print(" ")
                print(f"ProjectName: {FX_PROJECT_NAME}")
                print(f"ProjectId: {projectId}")
                print(f"EnvironmentName: {ENV_NAME}")
                print(f"EnvironmentId: {envId}")
                print(f"UpdatedBaseUrl: {UpdatedBaseUrl}")
                print(" ")



projResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/find-by-name/{FX_PROJECT_NAME}", headers=tokenheaders)
projErrors=projResp.json()['errors']
if projErrors == True:
    message=projResp.json()['messages'][0]['value']
    print(message + " so scanning cannot be triggered!!")
elif projErrors == False:
    URL=f"{FX_HOST}/api/v1/runs/project/{PROJECT_NAME}?jobName={PROFILE_NAME}&region={REGION}&categories={CAT}&emailReport={FX_EMAIL_REPORT}&reportType={FX_REPORT_TYPE}{FX_SCRIPT}"
    print(" ")
    print(f"The request is {URL}")
    scanResp = requests.request("POST", f"{URL}", headers=tokenheaders)
    scanErrors=scanResp.json()['errors']
    if scanErrors == True:
        message=projnResp.json()['messages'][0]['value']
        print(message + " so scanning cannot be triggered!!")
    
    elif scanErrors == False:
        scanData=scanResp.json()['data']
        projectId=scanData['job']['project']['id']
        runId=scanData['id']
        print(f"ProjectId: {projectId}")
        print(f"runId: {runId}")        
        taskStatus="WAITING"
        print(f"taskStatus = {taskStatus}")
        while taskStatus == "WAITING" or taskStatus == "PROCESSING":
            time.sleep(5)
            print(" ")
            print("Checking Status....")
            runResp = requests.request("GET", f"{FX_HOST}/api/v1/runs/{runId}", headers=tokenheaders)
            passPercent = runResp.json()['data']['ciCdStatus']
            array = passPercent.split(":")
            taskStatus=array[0]
            print(f"Status = {array[0]}  Success Percent = {array[1]}   Total Tests = {array[2]}  Total Failed = {array[3]}  Run = {array[6]}")
            if taskStatus == "COMPLETED":
                print(" ")
                print("------------------------------------------------")
                print(f"Run detail link {FX_HOST}{array[7]}")
                print("------------------------------------------------")
                print("Scan Successfully Completed!!")
                print("")
                
                if FX_EMAIL_REPORT == "true" or FX_EMAIL_REPORT == "True":
                    print("Will wait for 10 seconds")                    
                    time.sleep(10)
                    pgResp = requests.request("GET", f"{FX_HOST}/api/v1/runs/{runId}", headers=tokenheaders)
                    totalPGcount = pgResp.json()['data']['task']['totalTests']
                    esResp = requests.request("GET", f"{FX_HOST}/api/v1/runs/{runId}/test-suite-responses", headers=tokenheaders)
                    esData = esResp.json()['data']
                    totalEScount = [item.get('id') for item in esData]
                    esCount=0 
                    for scan in totalEScount:
                        esCount+= 1                       

                    if totalPGcount == esCount:
                        print("Email report will be sent in a short while!!")
                    else:
                        print("Email report will be sent after some delay!!")                        
                if FAIL_ON_VULN_SEVERITY_FLAG == True:
                    sevResp = requests.request("GET", f"{FX_HOST}/api/v1/projects/{projectId}/vulnerabilities?&severity=All&page=0&pageSize=20", headers=tokenheaders)                                    
                    sevData = sevResp.json()['data']                                        
                    severity = [item.get('severity') for item in sevData]

                    cVulCount=0
                    for vul in severity:
                        if  vul == "Critical":
                            cVulCount+= 1

                    print(f"Found {cVulCount} Critical Severity Vulnerabilities!!")
                    print(" ")

                    hVulCount=0
                    for vul in severity:
                        if  vul == "High":
                            hVulCount+= 1
                            
                    print(f"Found {hVulCount} High Severity Vulnerabilities!!")
                    print(" ")


                    majVulCount=0
                    for vul in severity:
                        if  vul == "Major":
                            majVulCount+= 1
                            
                    print(f"Found {majVulCount} Major Severity Vulnerabilities!!")
                    print(" ")

                    medVulCount=0
                    for vul in severity:
                        if  vul == "Medium":
                            medVulCount+= 1
                            
                    print(f"Found {medVulCount} Medum Severity Vulnerabilities!!")
                    print(" ")                  

                    minVulCount=0
                    for vul in severity:
                        if  vul == "Minor":
                            minVulCount+= 1
                            
                    print(f"Found {minVulCount} Minor Severity Vulnerabilities!!")
                    print(" ")

                    lowVulCount=0
                    for vul in severity:
                        if  vul == "Low":
                            lowVulCount+= 1
                            
                    print(f"Found {lowVulCount} Low Severity Vulnerabilities!!")
                    print(" ")

                    tVulCount=0
                    for vul in severity:
                        if  vul == "Trivial":
                            tVulCount+= 1
                            
                    print(f"Found {tVulCount} Trivial Severity Vulnerabilities!!")
                    print(" ")

                    if FAIL_ON_VULN_SEVERITY == "Critical":
                        for vul in severity:
                            if  vul == "Critical"  or vul == "High":
                                print(f"Failing script execution since we have found {cVulCount} Critical severity vulnerabilities!!!")
                                exit(1)

                    elif FAIL_ON_VULN_SEVERITY == "High":
                        for vul in severity:
                            if  vul == "Critical"  or vul == "High":
                                print(f"Failing script execution since we have found {cVulCount} Critical and {hVulCount} High severity vulnerabilities!!!")
                                exit(1)

                    elif FAIL_ON_VULN_SEVERITY == "Medium":
                        for vul in severity:
                            if  vul == "Critical"  or vul == "High" or vul == "Medium":
                                print(f"Failing script execution since we have found {cVulCount} Critical, {hVulCount} High and {medVulCount} Medium severity vulnerabilities!!!")
                                exit(1)


        if taskStatus == "TIMEOUT":
            print(f"Task Status = {taskStatus}")
            exi(1)


