#!/usr/bin/env bash
exec > >(tee -i /var/log/user-data.log)
exec 2>&1

# install prerequisites
amazon-linux-extras enable ansible2
yum clean metadata && yum update -y
yum install -y python-pip tar gzip bzip ansible
python -m pip install awscli boto botocore boto3

# create autoscaler work area
[ ! -d /usr/local/opt/asg ] && mkdir -p /usr/local/opt/asg
cd /usr/local/opt/asg
aws s3 cp s3://${Bucket_name} . --recursive

# required by Ansible SSM module
export AWS_DEFAULT_REGION=${region}

# run autoscaler installation#
ansible-playbook -i inventory/autoscaler autoscaler.yml -e "env=${env}" -e "nginx_resolver=${dns_resolver}" -vvvv
