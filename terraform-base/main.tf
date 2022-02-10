# Modules
module "network" {
  source            = "./modules/network"
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  enable_private    = var.enable_nat
  nat_id            = module.public.nat_id
}

module "public" {
  source            = "./modules/public"
  utopia_vpc_id     = module.network.utopia_vpc.id
  public_subnet     = module.network.public_subnet[*].id
  route53_zone_id   = var.route53_zone_id
  availability_zone = var.availability_zone
  bastion_ip        = var.bastion_ip
  nat_ip            = var.nat_ip
  enable_bastion    = var.enable_bastion
  enable_nat        = var.enable_nat
  ecs_record        = var.ecs_record

  bastion_init = templatefile("./scripts/bastion_init.sh", {
    password = var.vnc_password
  })
}
