# Modules
module "network" {
  # Module variables
  source = "./modules/network"

  # Variables
  cidr_block        = var.vpc_cidr
  availability_zone = var.availability_zone

  public_subnet  = var.public_subnet
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

  s3_bucket_name = var.jenkins_s3_bucket

  jenkins_startup = templatefile(var.jenkins_startup, {
    jenkins_user_id   = var.jenkins_user_id,
    jenkins_api_token = var.jenkins_api_token,
    jenkins_password  = var.jenkins_password
    jenkins_config    = file("./scripts/jenkins_config.yaml"),

    aws_access_key        = var.aws_access_key,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_ssh_key           = var.aws_ssh_key,

    aws_secret_region   = var.aws_secret_region,
    aws_secret_services = var.aws_secret_services,
    aws_ecs_secret      = var.aws_ecs_secret,
    aws_eks_secret      = var.aws_eks_secret,

    s3_bucket = var.jenkins_s3_bucket,
    sns_topic = var.sns_topic,
    user_id = var.aws_user_id
  })

  route53_zone_id = var.route53_zone_id
  route53_url = var.route53_url

  jenkins_config = {
    plugins_list = file("./scripts/jenkins_plugins.txt"),

    # KMS Encrypt and Decrypt Scripts
    KMS_ENCRYPT = file("./scripts/kms-encrypt.sh")
    KMS_DECRYPT = file("./scripts/kms-decrypt.sh")

    # Jenkins Service Pipelines
    users_pipeline_XML    = templatefile("./scripts/jenkins_job.xml", var.user_xml),
    flights_pipeline_XML  = templatefile("./scripts/jenkins_job.xml", var.flights_xml),
    bookings_pipeline_XML = templatefile("./scripts/jenkins_job.xml", var.bookings_xml),

    # Jenkins Deployment Pipelines
    ecs_deploy_XML = templatefile("./scripts/jenkins_job.xml", var.ecs_devops_xml),
    eks_deploy_XML = templatefile("./scripts/jenkins_job.xml", var.eks_devops_xml),
  }

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
  utopia_vpc_id  = module.network.utopia_vpc.id
  private_subnet = module.network.private_subnet.id
  bastion_ip     = module.public.bastion_ip
}
