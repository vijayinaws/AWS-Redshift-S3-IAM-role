
variable "environment" {}
variable "owner"             { }
variable "Charge_Code"       { }
variable "vpc_info" {
  type = "map"
}

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

variable "tags" {
  type    = "map"
  default = {}
}

resource "null_resource" "security_groups" {
  count = "${length(var.security_groups)}"

  triggers {
    vpc         = "${lookup(var.security_groups[count.index], "vpc")}"
    name        = "${lookup(var.security_groups[count.index], "name")}"
    description = "${lookup(var.security_groups[count.index], "description")}"
  }
}

resource "null_resource" "existing_security_groups" {
  count = "${length(var.existing_security_groups)}"

  triggers {
    vpc  = "${lookup(var.existing_security_groups[count.index], "vpc")}"
    name = "${lookup(var.existing_security_groups[count.index], "name")}"
    id   = "${lookup(var.existing_security_groups[count.index], "id")}"
  }
}

resource "null_resource" "cidr_ref_rules" {
  count = "${length(var.cidr_ref_rules)}"

  triggers {
    direction   = "${lookup(var.cidr_ref_rules[count.index], "direction")}"
    sg_name     = "${lookup(var.cidr_ref_rules[count.index], "sg_name")}"
    protocol    = "${lookup(var.cidr_ref_rules[count.index], "protocol")}"
    to_port     = "${lookup(var.cidr_ref_rules[count.index], "to_port")}"
    from_port   = "${lookup(var.cidr_ref_rules[count.index], "from_port")}"
    cidr        = "${lookup(var.cidr_ref_rules[count.index], "cidr")}"
    description = "${lookup(var.cidr_ref_rules[count.index], "description")}"
  }
}

resource "null_resource" "sg_ref_rules" {
  count = "${length(var.sg_ref_rules)}"

  triggers {
    direction   = "${lookup(var.sg_ref_rules[count.index], "direction")}"
    sg_name     = "${lookup(var.sg_ref_rules[count.index], "sg_name")}"
    protocol    = "${lookup(var.sg_ref_rules[count.index], "protocol")}"
    to_port     = "${lookup(var.sg_ref_rules[count.index], "to_port")}"
    from_port   = "${lookup(var.sg_ref_rules[count.index], "from_port")}"
    source_sg   = "${lookup(var.sg_ref_rules[count.index], "source_sg")}"
    description = "${lookup(var.sg_ref_rules[count.index], "description")}"
  }
}

resource "aws_security_group" "sg" {
  count = "${length(var.security_groups)}"

  name        = "${element(null_resource.security_groups.*.triggers.name, count.index)}"
  description = "${element(null_resource.security_groups.*.triggers.description, count.index)}"
  vpc_id      = "${lookup(var.vpc_info, element(null_resource.security_groups.*.triggers.vpc, count.index))}"

  tags = "${merge(var.tags, map(
    "Name",              element(null_resource.security_groups.*.triggers.name, count.index),
    "Terraform Managed", "TRUE",
    "Owner",             var.owner,
    "Environment",       var.environment,
    "Charge_Code",       var.Charge_Code,

  ))}"
}

resource "aws_security_group_rule" "cidr_rule" {
  count = "${length(var.cidr_ref_rules)}"

  description       = "${element(null_resource.cidr_ref_rules.*.triggers.description, count.index)}"
  security_group_id = "${element(concat(aws_security_group.sg.*.id, null_resource.existing_security_groups.*.triggers.id), index(concat(aws_security_group.sg.*.name, null_resource.existing_security_groups.*.triggers.name), element(null_resource.cidr_ref_rules.*.triggers.sg_name, count.index)))}"
  type              = "${element(null_resource.cidr_ref_rules.*.triggers.direction, count.index)}"
  cidr_blocks       = ["${split("|", element(null_resource.cidr_ref_rules.*.triggers.cidr, count.index))}"]
  protocol          = "${element(null_resource.cidr_ref_rules.*.triggers.protocol, count.index)}"
  from_port         = "${element(null_resource.cidr_ref_rules.*.triggers.from_port, count.index)}"
  to_port           = "${element(null_resource.cidr_ref_rules.*.triggers.to_port, count.index)}"
}

resource "aws_security_group_rule" "sg_rule" {
  count = "${length(var.sg_ref_rules)}"

  description       = "${element(null_resource.sg_ref_rules.*.triggers.description, count.index)}"
  security_group_id = "${element(concat(aws_security_group.sg.*.id, null_resource.existing_security_groups.*.triggers.id), index(concat(aws_security_group.sg.*.name, null_resource.existing_security_groups.*.triggers.name), element(null_resource.sg_ref_rules.*.triggers.sg_name, count.index)))}"
  type              = "${element(null_resource.sg_ref_rules.*.triggers.direction, count.index)}"

  source_security_group_id = "${element(concat(aws_security_group.sg.*.id, null_resource.existing_security_groups.*.triggers.id), index(concat(aws_security_group.sg.*.name, null_resource.existing_security_groups.*.triggers.name), element(null_resource.sg_ref_rules.*.triggers.source_sg, count.index)))}"
  protocol                 = "${element(null_resource.sg_ref_rules.*.triggers.protocol, count.index)}"
  from_port                = "${element(null_resource.sg_ref_rules.*.triggers.from_port, count.index)}"
  to_port                  = "${element(null_resource.sg_ref_rules.*.triggers.to_port, count.index)}"
}

output "sg_info" {
  value = "${zipmap(
               concat(aws_security_group.sg.*.name, null_resource.existing_security_groups.*.triggers.name),
               concat(aws_security_group.sg.*.id, null_resource.existing_security_groups.*.triggers.id)
          )}"
}

output "securitygroups" {
  value = "${concat(aws_security_group.sg.*.id)}"
}
