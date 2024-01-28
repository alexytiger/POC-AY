terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  required_version = ">= 1.2.0"
  backend "s3" {}  
}

provider "aws" {
  region = "${var.region}" 
}