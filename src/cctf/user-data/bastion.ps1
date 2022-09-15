<powershell>

# Installing Monaco Stuff
mkdir c:\monaco
mkdir c:\monaco-tools
cd 'C:\Program Files\Amazon\AWSCLI\bin\'
aws s3 sync s3://${s3_bucket_monaco_dashboard} c:\monaco --delete --region ${aws_region}
aws s3 sync s3://${s3_bucket_monaco_tools} c:\monaco-tools --delete --region ${aws_region}
Set-Content -Path 'C:\monaco\hercule\number.js' -Value "var ctfnumber = '${code}';"

New-Item 'c:\monaco-tools\aws_key.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\aws_key.txt' -Value "${aws_key}"

New-Item 'c:\monaco-tools\aws_secret.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\aws_secret.txt' -Value "${aws_secret}"

New-Item 'c:\monaco-tools\aws_username.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\aws_username.txt' -Value "${aws_username}"

New-Item 'c:\monaco-tools\aws_password.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\aws_password.txt' -Value "${aws_password}"

New-Item 'c:\monaco-tools\codecommit_ssh_id.txt' -ItemType file
Set-Content -Path 'c:\monaco-tools\codecommit_ssh_id.txt' -Value "${codecommit_ssh_id}"
#New-Item 'c:\monaco-tools\kubectl' -ItemType file

cp C:\monaco-tools\aws-iam-authenticator\aws-iam-authenticator.exe c:\windows\system32\
refreshenv
Restart-Service AmazonSSMAgent

</powershell>




