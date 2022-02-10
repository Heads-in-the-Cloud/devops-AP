# References
variable "utopia_vpc_id" { type = string }
variable "public_subnet" { type = list(string) }
variable "route53_zone_id" { type = string }
variable "availability_zone" { type = list(string) }

variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }

variable "bastion_init" { type = string }

variable "enable_bastion" { type = bool }
variable "enable_nat" { type = bool }

variable "ecs_record" { type = string }