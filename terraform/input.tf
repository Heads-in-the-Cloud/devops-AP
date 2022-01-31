# Input variables
variable "vpc_cidr" { type = string }

variable "public_subnet" { type = list(string) }
variable "private_subnet" { type = list(string) }

variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }
variable "jenkins_ip" { type = string }

variable "enable_jenkins" { type = bool }
variable "enable_bastion" { type = bool }
variable "enable_nat" { type = bool }
variable "enable_eks_cluster" { type = bool }

variable "availability_zone" { type = list(string) }

variable "jenkins_startup" { type = string }

variable "vnc_password" {
  type        = string
  description = "Password used for the bastion server's vnc server."
  sensitive   = true
}

variable "jenkins_user_id" {
  type        = string
  description = "Login id for the User id in Jenkins CLI"
  sensitive   = true
}

variable "jenkins_api_token" {
  type        = string
  description = "API Token for the User id in Jenkins CLI"
  sensitive   = true
}

variable "jenkins_password" {
  type        = string
  description = "Admin user password for Jenkins"
  sensitive   = true
}

variable "aws_access_key" {
  type        = string
  description = "AWS Access key"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access key"
  sensitive   = true
}

variable "aws_ssh_key" {
  type        = string
  description = "AWS ssh key used to access the instance"
  sensitive   = true
}

variable "aws_secret_region" {
  type        = string
  description = "AWS Region"
  sensitive   = true
}
variable "aws_secret_services" {
  type        = string
  description = "AWS Credentials url used in microservices"
  sensitive   = true
}
variable "aws_ecs_secret" {
  type        = string
  description = "AWS Credentials url used in ECS"
  sensitive   = true
}
variable "aws_eks_secret" {
  type        = string
  description = "AWS Credentials url used in EKS"
  sensitive   = true
}

variable "route53_zone_id" { type = string }
variable "route53_url" { type = string }

variable "jenkins_s3_bucket" { type = string }
variable "sns_topic" { type = string }
variable "aws_user_id" { type = string }

variable "user_xml" { type = map(string) }
variable "flights_xml" { type = map(string) }
variable "bookings_xml" { type = map(string) }

variable "ecs_devops_xml" { type = map(string) }
variable "eks_devops_xml" { type = map(string) }
