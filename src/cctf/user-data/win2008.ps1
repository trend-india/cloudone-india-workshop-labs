<powershell>

net accounts /maxpwage:UNLIMITED
net user Bryce xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Bryce Coleman" /Y
net user Joyce xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Joyce Hopper" /Y
net user Jim xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Jim Brenner" /Y
net user Nancy xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Nancy Byers" /Y
net user Jane xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Jane Wheeler" /Y
net user Dustin xgen-no-virus5! /ADD /PASSWORDCHG:NO /FULLNAME:"Dustin Powell" /Y
net user Bill t3chD@y! /ADD /PASSWORDCHG:NO /FULLNAME:"Bill Hawkins" /Y
net localgroup administrators Bryce /add
net localgroup administrators Bryce Joyce Jim Nancy Jane Stephanie Bill /add

Set-ExecutionPolicy AllSigned; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install firefox awscli -y
choco install awscli awstools.powershell cyberduck curl -y
refreshenv
Restart-Service AmazonSSMAgent

mkdir c:\installers
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
choco install nmap visualstudiocode tor-browser curl mobaxterm -y

aws s3 sync s3://ebc-installers c:\installers\
C:\installers\ec2\Ec2Install.exe /repair /quiet /norestart  /log c:\ec2install-repair.log
C:\installers\ec2\Ec2Install.exe /install /quiet /norestart  /log c:\ec2install-install.log

</powershell>




