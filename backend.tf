<<<<<<< HEAD
terraform {
  required_version = "0.11.5"

  backend "s3" {
    bucket         = "mcd-tfstates"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
=======
terraform {
  required_version = "0.11.5"

  backend "s3" {
    bucket         = "mcd-tfstates"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
>>>>>>> 0fe52dc20135dad13342a1b708e1053a75f1399a
