variable "existing_vpc" {
  type    = "list"
  default = []
}

variable "existing_subnets" {
  type    = "list"
  default = []
}

resource "null_resource" "existing_vpc" {
  count = "${length(var.existing_vpc)}"

  triggers {
    vpc_name   = "${lookup(var.existing_vpc[count.index], "vpc_name")}"
    vpc_id     = "${lookup(var.existing_vpc[count.index], "vpc_id")}"
  }
}

resource "null_resource" "existing_subnets" {
  count = "${length(var.existing_subnets)}"

  triggers {
    subnet_name              = "${lookup(var.existing_subnets[count.index], "subnet_name")}"
    subnet_id                = "${lookup(var.existing_subnets[count.index], "subnet_id")}"
  }
}

output "vpc_info" {
  value = "${zipmap(
               concat(null_resource.existing_vpc.*.triggers.vpc_name),
               concat(null_resource.existing_vpc.*.triggers.vpc_id)
          )}"
}

output "subnet_info" {
  value = "${zipmap(
               concat(null_resource.existing_subnets.*.triggers.subnet_name),
               concat(null_resource.existing_subnets.*.triggers.subnet_id)
          )}"
}
