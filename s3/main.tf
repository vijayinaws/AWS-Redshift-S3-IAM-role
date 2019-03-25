variable "environment" {}
variable "owner"             { }
variable "Charge_Code"       { }

variable "tags" { type = "map" }

variable "region" {}

variable "buckets" {
  type    = "list"
  default = []
}

resource "null_resource" "buckets" {
  count = "${length(var.buckets)}"

  triggers {
    name          = "${lookup(var.buckets[count.index], "name")}"
    versioning    = "${lookup(var.buckets[count.index], "versioning")}"
    force_destroy = "${lookup(var.buckets[count.index], "force_destroy", "False")}"
  }
}

resource "aws_s3_bucket" "bucket" {
  count = "${length(var.buckets)}"

  bucket        = "${element(null_resource.buckets.*.triggers.name, count.index)}"
  acl           = "private"
  region        = "${var.region}"
  force_destroy = "${element(null_resource.buckets.*.triggers.force_destroy, count.index)}"

  versioning {
    enabled = "${element(null_resource.buckets.*.triggers.versioning, count.index)}"
  }

  tags = "${merge(var.tags, map(
    "Name",              element(null_resource.buckets.*.triggers.name, count.index),
    "Terraform Managed", "TRUE",
    "Owner",             var.owner,
    "Environment",       var.environment,
    "Charge_Code",       var.Charge_Code,
  ))}"
}

output "s3" {
  value = "${concat(aws_s3_bucket.bucket.*.arn)}"
}