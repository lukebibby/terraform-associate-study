/* Providers */
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  shared_credentials_file = ".creds"
  region                  = "ap-southeast-2"
  alias                   = "sydney"
}

provider "aws" {
  shared_credentials_file = ".creds"
  region                  = "ap-southeast-1"
  alias                   = "singapore"
}

provider "random" {}