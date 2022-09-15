#!/bin/bash
exec &> /var/log/init-devops.log
set -o verbose
set -o errexit
set -o pipefail

yum install -y docker git
service docker start
$(aws ecr get-login --no-include-email --region ap-southeast-1)
aws s3 cp s3://henry-chan/gitconfig /root/.gitconfig
sleep 600

#docker run --name c8081 -p 8081:8080 -d  --restart unless-stopped 650143975734.dkr.ecr.ap-southeast-1.amazonaws.com/${name}-grapefruit
docker run --name c8082 -p 8082:80 -d --restart unless-stopped  650143975734.dkr.ecr.ap-southeast-1.amazonaws.com/${name}-melon
