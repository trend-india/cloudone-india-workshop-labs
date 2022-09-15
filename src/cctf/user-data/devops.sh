#!/bin/bash
exec &> /var/log/init-devops.log
set -o verbose
set -o errexit
set -o pipefail
sleep 300

yum install -y docker git
service docker start
$(aws ecr get-login --no-include-email --region ${aws_region})
aws s3 cp s3://${s3_bucket_monaco_code}/gitconfig /root/.gitconfig --region ${aws_region}


git clone https://${iam_user_codecommit_https_git_credentials_username}:${iam_user_codecommit_https_git_credentials_password}@git-codecommit.${aws_region}.amazonaws.com/v1/repos/${name}-CC-Template-Scanner /CC-Template-Scanner
cd /CC-Template-Scanner
BUILD=$(shuf -i 1000-9999 -n 1)
touch $BUILD
aws s3 sync  s3://${s3_bucket_monaco_code}/CC-Template-Scanner .  --exclude ".git/*" --region ${aws_region}
git add .
git commit -m 'new'
git push


git clone https://${iam_user_codecommit_https_git_credentials_username}:${iam_user_codecommit_https_git_credentials_password}@git-codecommit.${aws_region}.amazonaws.com/v1/repos/${name}-melon /melon
cd /melon
BUILD=$(shuf -i 1000-9999 -n 1)
touch $BUILD
aws s3 sync  s3://${s3_bucket_monaco_code}/monaco-melon .  --exclude ".git/*" --region ${aws_region}
rm -rf Jenkinsfile
mv Jenkinsfile-Scrubbed.groovy Jenkinsfile
git add .
git commit -m 'new'
git push

docker build -t melon .
docker tag melon:latest ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${name}-melon:latest
docker push ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${name}-melon:latest

git checkout -b fixer
git push -u origin fixer
docker tag melon:latest ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${name}-melon:fixer
docker push ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${name}-melon:fixer

docker run --name c8082 -p 8082:80 -d --restart unless-stopped  ${aws_account_id}.dkr.ecr.${aws_region}.amazonaws.com/${name}-melon
