# Input variables
variable "vpc_cidr" { type = string }
variable "availability_zone" { type = list(string) }

variable "public_subnet" { type = list(string) }
variable "private_subnet" { type = list(string) }

variable "enable_nat" { type = bool }
variable "enable_bastion" { type = bool }

variable "enable_eks_cluster" { type = bool }

variable "ecs_record" { type = string }

variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }

variable "vnc_password" {
  type        = string
  description = "Password used for the bastion server's vnc server."
  sensitive   = true
}

variable "route53_zone_id" { type = string }

variable "aws_user_id" { type = string }
