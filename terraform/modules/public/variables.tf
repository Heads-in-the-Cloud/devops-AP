# References
variable "utopia_vpc_id" { type = string }
variable "public_subnet" { type = string }

# Inputs
variable "availability_zone" { type = string }

variable "jenkins_ip" { type = string }
variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }

variable "vnc_password" { type = string }
variable "jenkins_startup" { type = string }

variable "enable_bastion" { type = bool }
variable "enable_nat" { type = bool }
variable "enable_jenkins" { type = bool }