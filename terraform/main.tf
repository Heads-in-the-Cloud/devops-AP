# Input variables
variable "vpc_cidr" { type = string }
variable "public_subnet" { type = string }
variable "private_subnet" { type = string }

variable "bastion_ip" { type = string }
variable "nat_ip" { type = string }
variable "jenkins_ip" { type = string }

variable "enable_bastion" { type = bool }
variable "enable_nat" { type = bool }
variable "enable_jenkins" { type = bool }
variable "enable_eks_cluster" { type = bool }

variable "availability_zone" { type = string }
variable "jenkins_startup" { type = string }

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

variable "aws_access_key" {
  type        = string
  description = "API Token for the User id in Jenkins CLI"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "API Token for the User id in Jenkins CLI"
  sensitive   = true
}

variable "aws_ssh_key" {
  type        = string
  description = "API Token for the User id in Jenkins CLI"
  sensitive   = true
}

variable "vnc_password" {
  type        = string
  description = "Password used for the bastion server's vnc server."
  sensitive   = true
}

# Modules
module "network" {
  # Module variables
  source = "./modules/network"

  # Variables
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet

  # Resource Enablers
  enable_private = var.enable_nat

  # References
  nat_id = module.public.nat_id
}

module "public" {
  # Module variables
  source = "./modules/public"

  # IP Addresses
  bastion_ip = var.bastion_ip
  nat_ip     = var.nat_ip
  jenkins_ip = var.jenkins_ip

  # Variables
  vnc_password      = var.vnc_password
  availability_zone = var.availability_zone
  jenkins_startup = templatefile(var.jenkins_startup, {
    jenkins_user_id       = var.jenkins_user_id,
    jenkins_api_token     = var.jenkins_api_token,
    jenkins_config        = file("./scripts/jenkins_config.yaml"),
    aws_access_key        = var.aws_access_key,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_ssh_key           = var.aws_ssh_key
  })

  # Resource Enablers
  enable_bastion = var.enable_bastion
  enable_nat     = var.enable_nat
  enable_jenkins = var.enable_jenkins

  # References
  utopia_vpc_id = module.network.utopia_vpc.id
  public_subnet = module.network.public_subnet.id
}

module "private" {
  # Module variables
  source = "./modules/private"
  count  = var.enable_nat ? 1 : 0

  # References
  utopia_vpc_id  = module.network.utopia_vpc.id
  private_subnet = module.network.private_subnet.id
  bastion_ip     = module.public.bastion_ip
}
