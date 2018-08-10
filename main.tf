terraform {
  backend "s3" {
    bucket = "rksandbox-tfstate"
    key    = "ecs.tfstate"
    region = "us-west-2"
  }
}

provider "aws" {
  profile = "${local.aws_profile}"
  region  = "${local.region}"
}

# Provides a global tags map
module "tags" {
  source = "git::ssh://git@github.com/2ndWatch/tfm_2w_tags.git?ref=1.0.0"

  tf_owner        = "Ryan Kennedy"
  tf_repo         = "github.com:ryno75/ecs_test_tf"
  tf_state_bucket = "rksandbox-tfstate"
  tf_state_key    = "ecs.tfstate"
  tf_template     = "ecs"
}

module "vpc" {
  source               = "git::ssh://git@github.com/2ndWatch/tfm_aws_vpc.git?ref=1.1.1"
  name                 = "ecs-vpc"
  cidr                 = "10.0.0.0/20"
  aws_region           = "us-west-2"
  enable_dns_hostnames = true
  enable_dns_support   = true
  flow_logs            = true
  availability_zones   = ["${local.availability_zones}"]
  private_subnets      = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
  public_subnets       = ["10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24"]
  nat_gateway          = true
  name_prefix          = "ecs-vpc-"
  s3_endpoint          = true
  tags                 = "${module.tags.tags}"
}

resource "aws_ecr_repository" "ecr_repos" {
  count = "${length(var.repositories)}"
  name  = "${var.repositories[count.index]}"
}

module "ecs-cluster" {
  source      = "github.com/terraform-community-modules/tf_aws_ecs.git?ref=v5.2.0"
  name        = "test-cluster"
  key_name    = "rktest"
  servers     = 1
  max_servers = 3
  subnet_id   = ["${module.vpc.private_subnets}"]
  vpc_id      = "${module.vpc.vpc_id}"
  extra_tags  = ["${module.tags.autoscaling_tags}"]
}
