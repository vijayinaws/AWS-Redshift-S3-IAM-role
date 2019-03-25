variable "environment" {}
variable "owner"             { }
variable "Charge_Code"       { }
variable "s3_bucket" {}
variable "redshift_clusters" {
  type    = "list"
  default = []
}

variable "redshift_subnet_groups" {
  type    = "list"
  default = []
}

variable "sg_info" {
  type = "map"
}

variable "subnet_info" {
  type = "map"
}

variable "tags" {
  type = "map"
  default = {}
}


# Resources
# -----------------------------------------------------

resource "null_resource" "redshift_clusters" {
  count = "${length(var.redshift_clusters)}"

  triggers {
    cluster_identifier = "${lookup(var.redshift_clusters[count.index], "cluster_identifier")}"
    username           = "${lookup(var.redshift_clusters[count.index], "username")}"
    database_name      = "${lookup(var.redshift_clusters[count.index], "database_name")}"
    security_groups    = "${lookup(var.redshift_clusters[count.index], "security_groups")}"
    node_type          = "${lookup(var.redshift_clusters[count.index], "node_type")}"
    cluster_type       = "${lookup(var.redshift_clusters[count.index], "cluster_type")}"
    password           = "${lookup(var.redshift_clusters[count.index], "password")}"
    number_of_nodes    = "${lookup(var.redshift_clusters[count.index], "number_of_nodes")}"
  }
}

resource "null_resource" "redshift_subnet_groups" {
  count = "${length(var.redshift_subnet_groups)}"

  triggers {
    name    = "${lookup(var.redshift_subnet_groups[count.index], "name")}"
    subnets = "${lookup(var.redshift_subnet_groups[count.index], "subnets")}"
  }
}

resource "aws_redshift_subnet_group" "subnet_group" {
  count = "${length(var.redshift_subnet_groups)}"

  name = "${element(null_resource.redshift_subnet_groups.*.triggers.name, count.index)}"

  subnet_ids = ["${matchkeys(
                    values(var.subnet_info),
                    keys(var.subnet_info),
                    split("|", element(null_resource.redshift_subnet_groups.*.triggers.subnets, count.index))
                  )}"]

  tags = "${merge(var.tags, map(
    "Name",              element(null_resource.redshift_subnet_groups.*.triggers.name, count.index),
    "Terraform Managed", "TRUE",
    "Owner",             var.owner,
    "Environment",       var.environment,
    "Charge_Code",       var.Charge_Code,
  ))}"
}

resource "aws_redshift_cluster" "redshiftcluster" {
  count = "${length(var.redshift_clusters)}"

  cluster_identifier        = "${element(null_resource.redshift_clusters.*.triggers.cluster_identifier, count.index)}"
  database_name             = "${element(null_resource.redshift_clusters.*.triggers.database_name, count.index)}"
  master_username           = "${element(null_resource.redshift_clusters.*.triggers.username, count.index)}"
  master_password           = "${element(null_resource.redshift_clusters.*.triggers.password, count.index)}"
  node_type                 = "${element(null_resource.redshift_clusters.*.triggers.node_type, count.index)}"
  iam_roles                 = ["${aws_iam_role.redshift_role.arn}"]
  cluster_type              = "${element(null_resource.redshift_clusters.*.triggers.cluster_type, count.index)}"
  number_of_nodes           = "${element(null_resource.redshift_clusters.*.triggers.number_of_nodes, count.index)}"
  cluster_subnet_group_name = "${element(null_resource.redshift_subnet_groups.*.triggers.name, count.index)}"
  vpc_security_group_ids    = ["${matchkeys(values(var.sg_info), keys(var.sg_info), compact(split("|", element(null_resource.redshift_clusters.*.triggers.security_groups, count.index))))}"]

  # TODO: Final Snapshot options
  skip_final_snapshot = true
}

output "redshift_cluster_endpoint" {
  value = "${aws_redshift_cluster.redshiftcluster.*.endpoint}"
}

resource "aws_iam_role" "redshift_role" {
  name = "redshift_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "redshift.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
      tag-key = "tag-value"
  }
}
resource "aws_iam_role_policy" "test_policy" {
  name = "test_policy"
  role = "${aws_iam_role.redshift_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "s3:ListBucket",
                "s3:PutObject",
                "s3:GetObject"
            ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${var.s3_bucket}/*"
            ]
    }
  ]
}
EOF
}

output "iam_role_arn" {
  value = "${aws_iam_role.redshift_role.*.arn}"
}

