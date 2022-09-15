<powershell>
# Creating User Accounts
net accounts /maxpwage:UNLIMITED
net user Bryce xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Bryce Coleman" /Y
net user John Id0ntkn0w! /ADD /PASSWORDCHG:NO /FULLNAME:"John Duck" /Y
net localgroup administrators Bryce John /add

# Installing Software

Set-ExecutionPolicy AllSigned; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install googlechrome visualstudiocode mobaxterm -y --ignore-checksum
choco install awscli awstools.powershell kubernetes-cli -y
choco install kubernetes-helm --version=2.15.1 -y

# Installing Monaco Stuff
mkdir c:\monaco
mkdir c:\monaco-tools
cd 'C:\Program Files\Amazon\AWSCLI\bin\'
.\aws.exe s3 sync s3://monacoo-dashboard c:\monaco --delete
.\aws.exe s3 sync s3://monacoo-tools c:\monaco-tools --delete
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
# Installing Secondary Stuff
mkdir c:\installers
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User") 
choco install nmap curl cyberduck mobaxterm -y
choco install firefox adobereader-update git 7zip python2 python3 -y
# Adding more Users
net user Joyce xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Joyce Hopper" /Y
net user Jim xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Jim Brenner" /Y
net user Nancy xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Nancy Byers" /Y
net user Jane xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Jane Wheeler" /Y
net user Dustin xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Dustin Powell" /Y
net user Bill t3chD@y! /ADD /PASSWORDCHG:NO /FULLNAME:"Bill Hawkins" /Y
net localgroup administrators Joyce Jim Nancy Jane Stephanie Bill /add

# Installing Deep Security
Start-Sleep -s 30
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$env:LogPath = "$env:appdata\Trend Micro\Deep Security Agent\installer"
New-Item -path $env:LogPath -type directory
echo "$(Get-Date -format T) - DSA download started"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
$baseUrl = "https://${dsmurl}:443/"
if ( [intptr]::Size -eq 8 ) { 
    $sourceUrl = -join ($baseurl, "software/agent/Windows/x86_64/") 
}
else {
    $sourceUrl = -join ($baseurl, "software/agent/Windows/i386/") 
}
echo "$(Get-Date -format T) - Download Deep Security Agent Package" $sourceUrl
(New-Object System.Net.WebClient).DownloadFile($sourceUrl, "$env:temp\agent.msi")
if ( (Get-Item "$env:temp\agent.msi").length -eq 0 ) {
    echo "Failed to download the Deep Security Agent. Please check if the package is imported into the Deep Security Manager. "
    exit 1 
}
echo "$(Get-Date -format T) - Downloaded File Size:" (Get-Item "$env:temp\agent.msi").length
echo "$(Get-Date -format T) - Installer Exit Code:" (Start-Process -FilePath msiexec -ArgumentList "/i $env:temp\agent.msi /qn ADDLOCAL=ALL /l*v `"$env:LogPath\dsa_install.log`"" -Wait -PassThru).ExitCode 
Start-Sleep -s 30
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -r
& $Env:ProgramFiles"\Trend Micro\Deep Security Agent\dsa_control" -a dsm://${dsmurl}:4120/ "policyid:${dsmpolicy}"



</powershell>




