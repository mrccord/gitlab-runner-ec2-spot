#!/bin/bash
sudo -i
###### Installing docker #######
sudo apt update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    jq \
    lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt-get install docker-ce docker-ce-cli containerd.io -y

usermod -a -G docker ubuntu
sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker

###### Installing Docker Machine #######

base=https://github.com/docker/machine/releases/download/v0.16.0 \
  && curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine \
  && sudo mv /tmp/docker-machine /usr/local/bin/docker-machine \
  && chmod +x /usr/local/bin/docker-machine


###### Installing gitlab runner #######

curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
sudo -E apt-get install gitlab-runner -y 

#### Runner Config #######

cat <<EOF > /etc/gitlab-runner/config.template.toml
[[runners]]
  limit = 6
  [runners.docker]
    privileged = true
    disable_cache = true
    tls_verify = false
    shm_size = 0
  [runners.cache]
    Type = "s3"
    Shared = true
    [runners.cache.s3]
      ServerAddress = "s3.amazonaws.com"
      AccessKey = "${aws_access_key}"
      SecretKey = "${aws_secret_key}"
      BucketName = "gitlab-runner-cache-s3-bizware"
      BucketLocation = "us-east-1"
  [runners.machine]
    IdleCount = 1
    MaxBuilds = 10
    MaxGrowthRate = 1
    MachineDriver = "amazonec2"
    MachineName = "gitlab-runner-%s"
    MachineOptions = [
      "amazonec2-access-key=${aws_access_key}", 
      "amazonec2-secret-key=${aws_secret_key}", 
      "amazonec2-ssh-user=ubuntu", 
      "amazonec2-region=us-east-1", 
      "amazonec2-instance-type=m4.xlarge",
      "amazonec2-vpc-id=${vpc_id}", 
      "amazonec2-subnet-id=${subnet_id}",
      "amazonec2-security-group=${security_group_name}",
      "amazonec2-use-private-address=true",
      "amazonec2-zone=a",
      "amazonec2-request-spot-instance=true", 
      "amazonec2-spot-price=0.09"
    ]
EOF

sudo gitlab-runner register \
      --config /etc/gitlab-runner/config.toml \
      --template-config /etc/gitlab-runner/config.template.toml \
      --non-interactive \
      --url https://gitlab.com \
      --registration-token ${gitlab_runner_registration_token} \
      --name gitlab-runner-manager \
      --locked="false" \
      --run-untagged="true" \
      --executor docker+machine \
      --docker-image alpine 

gitlab-runner verify
systemctl restart gitlab-runner

