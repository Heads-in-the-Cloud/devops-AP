# References
variable "utopia_vpc_id" { type = string }

variable "public_subnet" { type = list(string) }

# Inputs
variable "availability_zone" { type = list(string) }

variable "jenkins_ip" { type = string }
variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }
variable "sonarqube_ip" { type = string }

variable "vnc_password" { type = string }

variable "jenkins_startup" { type = string }
variable "jenkins_config" { type = map(string) }
variable "jenkins_s3_bucket" { type = string }
variable "jenkins_route53_url" { type = string }

variable "sonarqube_startup" { type = string }
variable "sonarqube_config" { type = map(string) }
variable "sonarqube_s3_bucket" { type = string }
variable "sonarqube_route53_url" { type = string }

variable "route53_zone_id" { type = string }

variable "enable_bastion" { type = bool }
variable "enable_nat" { type = bool }
variable "enable_jenkins" { type = bool }
variable "enable_sonarqube" { type = bool }