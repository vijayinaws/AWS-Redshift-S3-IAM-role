


#enter region for deployment
aws_region = "us-east-1"

# bucket name to add into redshift_iam_role_policy
s3_bucket = "us-east-1-dev-test-example"

#Tags
owner = "email_id"
environment = "dev_vpc"
Charge_Code = "1234"




existing_vpc = [
  {
    vpc_name   = "vpc-non_prod"
    vpc_id     = "vpc-a925c4d3"
  },
]

## Enter existing Subnet details. To add more existing subnets, copy the code block from { till } (including {}) and enter the details. Seperate the each code block with comman (,)
existing_subnets = [
  {
    subnet_id                = "subnet-4cbcd206"
    subnet_name              = "sub-non-prod-pub"
  },
  {
    subnet_id                = "subnet-fb4893a7"
    subnet_name              = "sub-non_prod-pub"
  },
]
## Enter the details to create NEW security group details. add more code blocks to create additional security groups, copy the code block from { till } (including {}) and enter the details. Seperate the each code block with comman (,)

security_groups = [
  {
    name        = "redshift-sg"
    vpc         = "vpc-non_prod"
    description = "Security Group for Load Balancers"
  },
]

## Enter the details to create security group rules, each rule should be in new code block. To add more code blocks, copy the code block from { till } (including {}) and enter the details. Seperate the each code block with comman (,)
cidr_ref_rules = [
  {
    sg_name     = "redshift-sg"
    direction   = "egress"
    protocol    = "-1"
    description = "outbound to Internet"
    to_port     = "0"
    from_port   = "0"
    cidr        = "0.0.0.0/0"
  },
  {
    sg_name     = "redshift-sg"
    direction   = "ingress"
    protocol    = "-1"
    description = "outbound to Internet"
    to_port     = "0"
    from_port   = "0"
    cidr        = "0.0.0.0/0"
  },
]
sg_ref_rules = [
  {
    sg_name     = "redshift-sg"
    direction   = "ingress"
    protocol    = "-1"
    description = "Inbound from Internet"
    to_port     = "0"
    from_port   = "65535"
    source_sg   = "redshift-sg"
    description = "Allow TCP traffic from test-cet"
  },
]

## Enter details to create S3 buckets, each bucket should be in new code block. To add more code blocks, copy the code block from { till } (including {}) and enter the details. Seperate the each code block with comman (,)

buckets = [
   {
     name       = "us-east-1-dev-test-example"
     versioning = "True"
     force_destroy = "True" 
   },
 ]

## Enter details to create Redshift , each Redshift should be in new code block. To add more code blocks, copy the code block from { till } (including {}) and enter the details. Seperate the each code block with comman (,)

 # Redshift

redshift_subnet_groups = [{
   name    = "test-subnet-group"
   subnets = "sub-non-prod-pub|sub-non_prod-pub"
 }]

 redshift_clusters = [
   {
     username           = "master"
     number_of_nodes    = "2"
     cluster_identifier = "us-east-test-redshift-cluster"
     cluster_type       = "multi"
     database_name      = "redshiftdb"
     node_type          = "ds2.xlarge"
     iam_roles          = ""
     encrypt            = "True"
     password           = "1qaz2wsX"
     security_groups    = "redshift-sg"
   },
 ]
 