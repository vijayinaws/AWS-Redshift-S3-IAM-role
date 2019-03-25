
output "sg_info" {
  value = "${module.security_groups.sg_info}"
}
 
output "s3" {
  value = "${module.s3.s3}"
}

output "redshift_cluster_endpoint" {
  value = "${module.redshift_cluster.redshift_cluster_endpoint}"
}

output "iam_role_arn" {
  value = "${module.redshift_cluster.iam_role_arn}"
}