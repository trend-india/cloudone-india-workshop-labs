<powershell>

# Installing Monaco Stuff
mkdir c:\monaco
mkdir c:\monaco-tools
cd 'C:\Program Files\Amazon\AWSCLI\bin\'
aws s3 sync s3://cloudone-india-monaco-dashboard c:\monaco --delete
aws s3 sync s3://cloudone-india-monaco-tools c:\monaco-tools --delete
New-Item 'c:\monaco-tools\attacker_website.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\attacker_website.txt' -Value "http://${attacker_website}:5000"

New-Item 'c:\monaco-tools\Splunk_URL.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\Splunk_URL.txt' -Value "http://${Splunk_URL}:8000"

New-Item 'c:\monaco-tools\Splunk_password.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\Splunk_password.txt' -Value "SPLUNK-${Splunk_Pass}"

New-Item 'c:\monaco-tools\workload_ip.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\workload_ip.txt' -Value "${workload_ip}"

cp C:\monaco-tools\aws-iam-authenticator\aws-iam-authenticator.exe c:\windows\system32\
refreshenv
Restart-Service AmazonSSMAgent

</powershell>
