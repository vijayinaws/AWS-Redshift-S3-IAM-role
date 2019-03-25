variable "environment"       { }
variable "owner"             { }
variable "Charge_Code"       { }
variable "aws_region"        { }

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

## Tagging
variable "global_tags" {
  type = "map"
  default = {}
}

variable "vpc_tags" {
  type = "map"
  default = {}
}

variable "sg_tags" {
  type = "map"
  default = {}
}



## VPC

variable "existing_vpc" {
  type    = "list"
  default = []
}

variable "existing_subnets" {
  type    = "list"
  default = []
}


## Security Groups
variable "security_groups" {
  type    = "list"
  default = []
}

variable "existing_security_groups" {
  type    = "list"
  default = []
}

variable "cidr_ref_rules" {
  type    = "list"
  default = []
}

variable "sg_ref_rules" {
  type    = "list"
  default = []
}

## S3
variable "buckets" {
  type    = "list"
  default = []
}
## REDSHIFT
variable "redshift_clusters" {
  type    = "list"
  default = []
}

variable "redshift_subnet_groups" {
  type    = "list"
  default = []
}

variable "s3_bucket" { default = "" }
