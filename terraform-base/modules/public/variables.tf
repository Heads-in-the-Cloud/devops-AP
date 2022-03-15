# References
variable "utopia_vpc_id" { type = string }
variable "public_subnet" { type = list(string) }
variable "route53_zone_id" { type = string }
variable "availability_zone" { type = list(string) }

variable "nat_ip" { type = string }

variable "ecs_record" { type = string }
variable "eks_record" { type = string }
