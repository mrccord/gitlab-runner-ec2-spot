# Gitlab Runner con aws ec2 spot instances

[Gitlab runner en aws](https://docs.gitlab.com/runner/configuration/runner_autoscale_aws/) la configuracion de este proyecto fue realizada en base a la documentacion de gitlab.

# Getting started with AWS and Terraform

## Create an User in AWS console with (AmazonEC2FullAccess) and (AmazonS3FullAccess) and save access token

## Amazon CLI with docker

```
# Run Amazon CLI
docker run -it -v ${PWD}:/work -w /work --entrypoint /bin/sh amazon/aws-cli:2.0.17

# some tools 
yum install -y jq gzip nano tar git unzip wget

# if you want to use again
docker exec -it CONTAINER_ID /bin/sh

```

## Login to Amazon

```
# Create your access key in your aws account
# you have to use access key id and secret key for configure aws

aws configure

```

## Get terraform
```
yum install -y yum-utils
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
yum -y install terraform

```
## Replace variables.tf values with environment variables and Use terraform

```
# Go to proyect

cd /my/proyect

cat <<EOF >>my-file-with-envs.sh
#!/bin/sh
export TF_VAR_region=us-east-1
export TF_VAR_gitlab_runner_registration_token="examplepAwsuj5ZpQotPN"
export TF_VAR_aws_access_key="EXAMPLETOKENU6LTRNCLO3KXK3"
export TF_VAR_aws_secret_key="exampletokenELoJBuwWBo/gM3W8Nr+CdfEvRN"
EOF

. ./my-file-with-envs.sh

terraform init
terraform plan
terraform apply
```

