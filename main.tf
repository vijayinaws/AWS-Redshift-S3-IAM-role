data "aws_availability_zones" "available" {}

module "existing_vpc" {
  source = "./existing_vpc"
  
  existing_vpc       = "${var.existing_vpc}"
  existing_subnets   = "${var.existing_subnets}"
}

module "security_groups" {
  source = "./security_groups"

  security_groups          = "${var.security_groups}"
  existing_security_groups = "${var.existing_security_groups}"
  cidr_ref_rules           = "${var.cidr_ref_rules}"
  sg_ref_rules             = "${var.sg_ref_rules}"
  vpc_info                 = "${module.existing_vpc.vpc_info}"
  tags                     = "${merge(var.global_tags)}"
  environment        = "${var.environment}"
  owner              = "${var.owner}"
  Charge_Code         = "${var.Charge_Code}"
}

module "s3" {
  source = "./s3"

  buckets       = "${var.buckets}"
  region        = "${var.aws_region}"
  tags          = "${merge(var.global_tags)}"
  environment        = "${var.environment}"
  owner              = "${var.owner}"
  Charge_Code         = "${var.Charge_Code}"
}

module "redshift_cluster" {
  source = "./redshift"

  redshift_subnet_groups = "${var.redshift_subnet_groups}"
  redshift_clusters      = "${var.redshift_clusters}"
  sg_info                = "${module.security_groups.sg_info}"
  subnet_info            = "${module.existing_vpc.subnet_info}"
  tags                   = "${merge(var.global_tags)}"
  s3_bucket              = "${var.s3_bucket}"
  environment        = "${var.environment}"
  owner              = "${var.owner}"
  Charge_Code         = "${var.Charge_Code}"
}