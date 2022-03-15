# Input variables
variable "vpc_cidr" { type = string }
variable "availability_zone" { type = list(string) }

variable "public_subnet" { type = list(string) }
variable "private_subnet" { type = list(string) }

variable "nat_ip" { type = string }

variable "route53_zone_id" { type = string }
variable "aws_user_id" { type = string }

variable "ecs_record" { type = string }
variable "eks_record" { type = string }

variable "resource_secret_name" { type = string }