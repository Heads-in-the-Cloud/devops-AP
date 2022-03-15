# - ---- ---- ---- ---- ---- ---- ---- ---- ---- ----

# Common ---- ---- ---- ---- ---- ---- ---- ---- ----
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "route53_zone_id" { type = string }
variable "availability_zone" { type = string }
variable "sns_topic" { type = string }
variable "aws_user_id" { type = string }

# Jenkins --- ---- ---- ---- ---- ---- ---- ---- ----
variable "jenkins_ip" { type = string }
variable "jenkins_startup" { type = string }
variable "jenkins_s3_bucket" { type = string }
variable "jenkins_route53_url" { type = string }
variable "enable_jenkins" { type = bool }

# SonarQube - ---- ---- ---- ---- ---- ---- ---- ----
variable "sonarqube_ip" { type = string }
variable "sonarqube_startup" { type = string }
variable "sonarqube_s3_bucket" { type = string }
variable "sonarqube_route53_url" { type = string }
variable "enable_sonarqube" { type = bool }

# Jenkins User Script Variables - ---- ---- ---- ----
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
variable "terraform_secret" {
  type        = string
  description = "Secrets Manager url used for Terraform in Jenkins"
  sensitive   = true
}
variable "sonarqube_token" {
  type        = string
  description = "SonarQube API Token"
  sensitive   = true
}
variable "resource_secret_name" {
  type        = string
  description = "URL for terraform outputs"
  sensitive   = true
}

# SonarQube User Script Variables ---- ---- ---- ----

# Jenkins S3 Config Files -- ---- ---- ---- ---- ----
variable "user_xml" { type = map(string) }
variable "flights_xml" { type = map(string) }
variable "bookings_xml" { type = map(string) }
variable "ecs_devops_xml" { type = map(string) }
variable "eks_devops_xml" { type = map(string) }
variable "terraform_xml" { type = map(string) }

# SonarQube S3 Config Files  ---- ---- ---- ---- ----
