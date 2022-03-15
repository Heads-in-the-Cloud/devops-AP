# References
variable "utopia_vpc_id" { type = string }
variable "private_subnet" { type = list(string) }

# Input
variable "bastion_ip" { type = string }