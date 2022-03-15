terraform {
	required_providers {
		aws = {
			source = "hashicorp/aws"
			version = "~> 3.0"
		}
	}
	backend "s3" {
		bucket = "ap-tf-utopia-state"
		key    = "terraform_state"
		region = "us-east-2"
	}
}

provider "aws" {
	region = "us-east-2"
}