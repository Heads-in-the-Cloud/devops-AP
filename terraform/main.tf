# Input
variable "vnc_password" {
    type = string
    description = "Password used for the bastion server's vnc server."
    sensitive = true
}

# Modules
module "network" {
    source = "./modules/network"
    cidr_block      = "10.0.0.0/16"
    public_subnet   = "10.0.1.0/24"
    private_subnet  = "10.0.2.0/24"
    nat_id          = module.public.nat_id
}

module "public" {
    source = "./modules/public"
    utopia_vpc_id   = module.network.utopia_vpc.id
    public_subnet   = module.network.public_subnet.id
    bastion_ip      = "10.0.1.100"
    nat_ip          = "10.0.1.200"
    vnc_password    = var.vnc_password
}

module "private" {
    source = "./modules/private"
    utopia_vpc_id   = module.network.utopia_vpc.id
    private_subnet  = module.network.private_subnet.id
    bastion_ip      = module.public.bastion_ip
    jenkins_ip      = "10.0.2.100"
}