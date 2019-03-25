# AWS Redshift, security groups, s3, IAM Roles.
This project provides the base Terraform code required to build infrastructure into aws account. 
This project is unique in that it provides the ability to build any number of resources dynamically based on input variables.
The Terraform code in this project is written in a way that it can service all environments for all project builds, without the need to modify any of the code within this project. 
All resource specification and customization is done purely through variables files.

**Table of Contents**
1.  - How to structure team repositories
    1. [Terraform VariablesFiles](#terraform-vars) - How to build variables files.

## Application Team Repositories

Each application should contain a Terraform variables file (tfvars) for each environment build.
The variables files should be named based on the environment name. 
For example, the `dev` environment should have a corresponding `dev.tfvars` file.

**Sample repository layout**
~~~
example
├── dev.tfvars
└── prod.tfvars
~~~

**terraform base modules with tfvars diagram**
~~~
└── live
    ├── terraform.tfvars
    │
    ├── app1
    │   ├── dev
    │   │   └── dev.tfvars
    │   │  
    │   ├── qa
    │   │  └── qa.tfvars
    │   │   
    │   └── prod
    │      └── prod.tfvars
    │       
    └── app2
        ├── dev
        │   └── dev.tfvars
        │   
        ├── qa
        │   └── qa.tfvars
        │  
        └── prod
            └── prod.tfvars
            
	 
└── modules
    └── app
	    ├─ main.tf
	    ├─ random_others.tf
            └─ variables.tf
~~~



#### Required Variables
The following list of variables are required for all infrastructure builds:


* **aws_region**: The AWS Region to launch infrastructure into



#### Optional Variables

Optional variables consist of lists from _0..N_ resources to buld. If non specified, they will be accepted as empty lists, and will effectively be trated as a no-op. The following example uses the S3 module to demonstrate building any number of S3 buckets.

Build no buckets
~~~
buckets = []
~~~

Build 1 bucket
~~~
buckets = [
  { name = "example-bucket-1", versioning = "true" }
]
~~~

Build 3 buckets
~~~
buckets = [
  { name = "example-bucket-1", versioning = "true"  },
  { name = "example-bucket-2", versioning = "true"  },
  { name = "example-bucket-3", versioning = "false" }
]
~~~


Each of the optional resources work in this manner. Most of the parameters come directly from the Terraform resources and can be referenced via the [Terraform documentation](https://www.terraform.io/docs/providers/aws/index.html). 


##### Existing Infrastructure Variables
There are a number of variables to allow your resources to reference already existing (shared) resources. For example, to launch instances into an existing VPC. These should be setup with a referencable name and correct AWS identifiers.

* **existing_vpc**: specify the `vpc_name`, `vpc_region`, `vpc_cidr`, and `vpc_id` for an existing VPC
* **existing_subnets**: specify the `subnet_type`, `subnet_cidr`, `subnet_id`, `subnet_name`, `vpc` (name), and `subnet_availability_zone` of an existing subnet.
* **existing_security_groups**: specify the `name`, `vpc` (name), and `id` of en existing security groups.


Once these have been "imported" through variables, you can referene them by their `name` parameter in other dependent resources.


##### New Infrastructure Variables
All other variables in the project are used to specify new resources.

* **security_groups**: creates new security groups
* **cidr_ref_rules**: creates new cidr referenced security group rules
* **sg_ref_rules**: creates new security group referenced security group rules
* **buckets**: creates s3 buckets
* **redshift_clusters**: creates redshift clusters
* **redshift_subnet_groups**: creates subnet groups for redshift clusters

> Note: The "tags" variables are used to apply additional tags that are desired at a global or a respirce specific level. These maps are merged into each other where the most specific tag will take precedence. For example, if the `global_tags` and `ec2_tags` variables both define the same key, the value from the `ec2_tags` map will be used. All mandatory tag variables, such as `business_unit`, take ultimate precidence and cannot be overwritten.


# execution steps: 


terraform init
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
terraform destroy -var-file="dev.tfvars

# Modules
 * S3 

 * redshift
    * main - terraform base code to create redshift cluster, subnet group and iam role with allow read/write to s3 policy

 * security_groups
     * main - base terraform code to create security_group with inbound/outbound rules

 * existing_vpc
     * main - base terraform code to use existing vpc and subnet details

# OUTPUT:
Apply complete! Resources: 9 added, 1 changed, 0 destroyed.

Outputs:

iam_role_arn = [
    arn:aws:iam::031479821455:role/redshift_role
]
redshift_cluster_endpoint = [
    us-east-test-redshift-cluster.c3r0qwfokil7.us-east-1.redshift.amazonaws.com:5439
]
s3 = [
    arn:aws:s3:::us-east-1-dev-test-example
]
sg_info = {
  redshift-sg = sg-0fd86e255d6cf7b24
}


