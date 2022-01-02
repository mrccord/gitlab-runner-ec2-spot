module "vpc" {
  source = "./modules/vpc"

  region   = var.region
  vpc_cidr = "10.1.0.0/16"
}

module "subnets" {
  source = "./modules/subnets"

  vpc_id                 = module.vpc.vpc_id
  route_table_id         = module.vpc.route_table_id
  default_route_table_id = module.vpc.default_route_table_id
  cidr_block             = "10.1.1.0/24"
  availability_zone      = "us-east-1a"
}

module "ec2" {
  source                           = "./modules/ec2"
  subnet_id                        = module.subnets.subnet_id
  vpc_id                           = module.vpc.vpc_id
  my_public_key                    = "./modules/ec2/public_key/id_rsa.pub"
  gitlab_runner_registration_token = var.gitlab_runner_registration_token
  aws_access_key                   = var.aws_access_key
  aws_secret_key                   = var.aws_secret_key
}

module "s3" {
  source = "./modules/s3"
}
