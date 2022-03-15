# References
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "route53_zone_id" { type = string }
variable "availability_zone" { type = string }

# Inputs
variable "private_ip" { type = string }
variable "user_data" { type = string }
variable "s3_config" { type = map(string) }
variable "s3_bucket" { type = string }
variable "route53_url" { type = string }