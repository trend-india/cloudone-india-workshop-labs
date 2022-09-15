#!/bin/bash
exec &> /var/log/dsm-install.log
curl -o /tmp/epel-release-latest-7.noarch.rpm https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y /tmp/epel-release-latest-7.noarch.rpm
yum install -y python-pip
pip install --upgrade pip
pip install awscli
mkdir -p installers

mkdir -p /opt/fastdsm/
aws s3 sync s3://bryce-installers/ds120/ /opt/fastdsm/

cd /opt/fastdsm/

#setup repos
curl -O https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install epel-release-latest-7.noarch.rpm
yum-config-manager --add-repo https://docs.docker.com/engine/installation/linux/repo_files/centos/docker.repo
yum makecache fast

sudo tee /etc/yum.repos.d/docker.repo <<-EOF
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

echo "$(date) -- starting docker Install" >> /var/log/dsm-install

# get a db
echo "$(date) -- RHEL7 on EC2 is occasionally slow to get enough network to find mirrors. Let it catch up"  >> /var/log/dsm-install
sleep 30
yum -y install docker-engine
service docker start
echo "$(date) -- creating pgsql container for dsmdb"  >> /var/log/dsm-install
docker pull postgres:9
docker run --name dsmpgsqldb -p 5432:5432 -e "POSTGRES_PASSWORD=${dbpw}"  -e POSTGRES_DB=dsm -d postgres:9
echo "$(date) -- creating database in sql instance"  >> /var/log/dsm-install

# persist db across restart
echo "$(date) -- creating service config to persiste db instance"  >> /var/log/dsm-install
curl https://s3.amazonaws.com/424d57/fastDsm/docker-dsmdb -o /etc/init.d/docker-dsmdb
chmod 755 /etc/init.d/docker-dsmdb
chkconfig --add docker-dsmdb
chkconfig docker-dsmdb on


# make a properties file
echo "$(date) -- creating dsm properties file" >> /var/log/dsm-install
echo "AddressAndPortsScreen.ManagerPort=443" >> dsm.props
echo "AddressAndPortsScreen.HeartbeatPort=4120" >> dsm.props
echo "AddressAndPortsScreen.ManagerAddress=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)" >> dsm.props
echo "CredentialsScreen.Administrator.Username=${dsmuser}" >> dsm.props
echo "CredentialsScreen.UseStrongPasswords=False" >> dsm.props
echo "CredentialsScreen.Administrator.Password=${dsmpw}" >> dsm.props
echo "SecurityUpdatesScreen.UpdateComponents=True" >> dsm.props
echo "DatabaseScreen.DatabaseType=PostgreSQL" >> dsm.props
echo "DatabaseScreen.Hostname=localhost:5432" >> dsm.props
echo "DatabaseScreen.Username=postgres" >> dsm.props
echo "DatabaseScreen.Password=${dbpw}" >> dsm.props
echo "DatabaseScreen.DatabaseName=dsm" >> dsm.props
echo "SecurityUpdateScreen.UpdateComponents=true" >> dsm.props
echo "SecurityUpdateScreen.UpdateSoftware=true" >> dsm.props
echo "SmartProtectionNetworkScreen.EnableFeedback=false" >> dsm.props
echo "SmartProtectionNetworkScreen.IndustryType=blank" >> dsm.props
echo "RelayScreen.Install=True" >> dsm.props
echo "RelayScreen.AntiMalware=True" >> dsm.props
echo "Override.Automation=True" >> dsm.props
echo "LicenseScreen.License.-1=${license}" >> dsm.props
# install manager
echo "$(date) -- installing manager" >> /var/log/dsm-install
chmod 755 Manager-Linux.sh
./Manager-Linux.sh -q -console -varfile dsm.props
echo "$(date) -- manager install complete" >> /var/log/dsm-install

# customize dsm
yum -y install perl-XML-Twig
echo "$(date) -- starting manager customization" >> /var/log/dsm-install
curl -O https://s3.amazonaws.com/trend-micro-quick-start/v5.1/Common/Scripts/set-aia-settings.sh
chmod 755 set-aia-settings.sh
curl -O https://s3.amazonaws.com/trend-micro-quick-start/v3.7/Common/Scripts/set-lbSettings
chmod 755 set-lbSettings
curl -O https://raw.githubusercontent.com/deep-security/ops-tools/master/deepsecurity/manager-apis/bash/ds10-rest-cloudAccountCreateWithInstanceRole.sh
chmod 755 ds10-rest-cloudAccountCreateWithInstanceRole.sh
curl https://s3.amazonaws.com/trend-micro-quick-start/v5.2/Common/Scripts/dsm_s.service -o /etc/systemd/system/dsm_s.service
chmod 755 /etc/systemd/system/dsm_s.service


echo "$(date) -- waiting for manager startup to complete" >> /var/log/dsm-install
until curl -vk https://127.0.0.1:443/rest/status/manager/current/ping; do echo \"manager not started yet\" >> /tmp/4-check-service; service dsm_s start >> /tmp/4-check-service; sleep 30; done
echo "$(date) -- manager startup complete. continuing with API call customizations" >> /var/log/dsm-install
./set-aia-settings ${dsmuser} ${dsmpw} localhost 443
name=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
if [ -z $name ]; then name=$(curl http://169.254.169.254/latest/meta-data/public-ipv4); fi
./set-lb-settings ${dsmuser} ${dsmpw} $name 443 4120
./ds10-rest-cloudAccountCreateWithInstanceRole.sh ${dsmuser} ${dsmpw} localhost 443


echo "$(date) -- completed manager customizations" >> /var/log/dsm-install
echo "service docker start" >> /etc/rc.local
echo "service docker-dsmdb start" >> /etc/rc.local
echo "service dsm_s start" >> /etc/rc.local
service dsm_s start

chkconfig docker-dsmdb on
chkconfig dsm_s on


aws s3 sync s3://bryce-installers/ds110/ /opt/fastdsm/
chmod +x /opt/fastdsm/run_docker.sh
chmod +x /opt/fastdsm/run_dsm_s.sh
chmod +x /opt/fastdsm/run_dsmdb.sh
line="*/2 * * * * /opt/fastdsm/run_dsmdb.sh"
(crontab -u root -l; echo "$line" ) | crontab -u root -
line="*/2 * * * * /opt/fastdsm/run_dsm_s.sh"
(crontab -u root -l; echo "$line" ) | crontab -u root -
line="*/2 * * * * /opt/fastdsm/run_docker.sh"
(crontab -u root -l; echo "$line" ) | crontab -u root -
yum install -y htop