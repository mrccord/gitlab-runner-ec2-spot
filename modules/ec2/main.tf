data "aws_ami" "gitlab-runner-ami" {
  owners      = ["099720109477"]
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "key-pair-gitlab-runner" {
  key_name   = "gitlab-runner-key-pair"
  public_key = file(var.my_public_key)
}

resource "aws_instance" "gitlab-runner-ec2-manager" {
  ami                    = data.aws_ami.gitlab-runner-ami.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key-pair-gitlab-runner.id
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.sg-gitlab-runner.id]
  user_data              = data.template_file.config.rendered
  tags = {
    Name = "gitlab-runner-ec2-manager"
  }
}

data "template_file" "config" {
  template = file("${path.module}/config/installing-runner.tpl")
  vars = {
    gitlab_runner_registration_token = var.gitlab_runner_registration_token
    aws_access_key                   = var.aws_access_key
    aws_secret_key                   = var.aws_secret_key
    subnet_id                        = var.subnet_id
    vpc_id                           = var.vpc_id
    security_group_name              = aws_security_group.sg-gitlab-runner.name
  }
}

resource "aws_security_group" "sg-gitlab-runner" {
  name   = "gitlab-runner-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "sg-gitlab-runner"
  }
}

resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-gitlab-runner.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "docker_inbound_access" {
  from_port         = 2376
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-gitlab-runner.id
  to_port           = 2376
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "docker_swarm_inbound_access" {
  from_port         = 3376
  protocol          = "tcp"
  security_group_id = aws_security_group.sg-gitlab-runner.id
  to_port           = 3376
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sg-gitlab-runner.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

