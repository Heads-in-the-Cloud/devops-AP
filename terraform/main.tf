# Modules
module "network" {
  # Module variables
  source = "./modules/network"

  # Variables
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone

  public_subnet   = var.public_subnet
  private_subnet = var.private_subnet

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
    jenkins_user_id   = var.jenkins_user_id,
    jenkins_api_token = var.jenkins_api_token,
    jenkins_password  = var.jenkins_password
    jenkins_config    = file("./scripts/jenkins_config.yaml"),

    aws_access_key        = var.aws_access_key,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_ssh_key           = var.aws_ssh_key,

    users_pipeline_XML    = templatefile("./scripts/jenkins_job.xml", var.user_xml),
    flights_pipeline_XML  = templatefile("./scripts/jenkins_job.xml", var.flights_xml),
    bookings_pipeline_XML = templatefile("./scripts/jenkins_job.xml", var.bookings_xml),
    ecs_deploy_XML        = templatefile("./scripts/jenkins_job.xml", var.devops_xml),

    plugins_list = file("./scripts/jenkins_plugins.txt")
  })

  # Resource Enablers
  enable_bastion = var.enable_bastion
  enable_nat     = var.enable_nat
  enable_jenkins = var.enable_jenkins

  # References
  utopia_vpc_id = module.network.utopia_vpc.id
  public_subnet = module.network.public_subnet[*].id
}

module "private" {
  # Module variables
  source = "./modules/private"
  count  = var.enable_nat ? 1 : 0

  # References
  utopia_vpc_id   = module.network.utopia_vpc.id
  private_subnet  = module.network.private_subnet.id
  bastion_ip      = module.public.bastion_ip
}
