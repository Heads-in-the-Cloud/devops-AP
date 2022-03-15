# Modules
module "network" {
  source            = "./modules/network"
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone
  public_subnet     = var.public_subnet
  private_subnet    = var.private_subnet
  nat_id            = module.public.nat_id
}

module "public" {
  source            = "./modules/public"
  utopia_vpc_id     = module.network.utopia_vpc.id
  public_subnet     = module.network.public_subnet[*].id
  route53_zone_id   = var.route53_zone_id
  availability_zone = var.availability_zone
  nat_ip            = var.nat_ip
  ecs_record        = var.ecs_record
  eks_record        = var.eks_record
}
