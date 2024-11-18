# Import the requests library
import sys
import requests
#from config import defect_dojo_Api
from aws_call import get_secret


#Variables and Values
secret_name = 'Defectdojo'

#getsecret variables
defect_dojo_Api ="Token" +' ' + get_secret(secret_name)

#the url to the DefectDojo API
url= 'https://demo.defectdojo.org/api/v2/import-scan'


#set the file name to the first argument
filename=sys.argv[1]

#if else statement to check the scan type
scan_report = ''
if filename == 'zap_report.json':
    scan_report = 'ZAP Scan'
elif filename == 'trivyartifact.json':
    scan_report = 'Trivy Scan'
elif filename == 'dependency-check-report.xml':
    scan_report = 'Dependency Check Scan'
elif filename == 'semgrep-report.json':
    scan_report = 'Semgrep JSON Report'
elif filename == 'gitleaks-report.json':
    scan_report = 'Gitleaks Scan'


#header for the request 
headers={'Authorization':defect_dojo_Api}

#data for the request
data = {'active': 'true',
        'verified': 'true',
        'scan_type':scan_report,
        'minimum_severity': 'Medium',
        'engagement': '[insert engagement id here]',
       }

#open the file and read it
files ={'file': open(filename, 'rb')}

#send the request
response= requests.post(url, headers=headers, files=files, data=data)

#check the response
if response.status_code == 201:
    print('Scan uploaded successfully')
else:
    print('Error uploading scan')
    print(response.text)