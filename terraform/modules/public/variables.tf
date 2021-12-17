# References
variable "utopia_vpc_id" { type = string }
variable "public_subnet" { type = string }

# Inputs
variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }

variable "vnc_password" { type = string }