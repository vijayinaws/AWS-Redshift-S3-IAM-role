terraform {
  required_version = "0.11.5"

  backend "s3" {
    bucket         = "mcd-tfstates"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}
