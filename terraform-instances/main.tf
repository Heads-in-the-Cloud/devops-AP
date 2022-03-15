# Modules
module "jenkins" {
  source = "./modules/jenkins"
  count  = var.enable_jenkins ? 1 : 0

  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  route53_zone_id   = var.route53_zone_id
  availability_zone = var.availability_zone

  private_ip = var.jenkins_ip
  user_data = templatefile(var.jenkins_startup, {
    jenkins_user_id       = var.jenkins_user_id,
    jenkins_api_token     = var.jenkins_api_token,
    jenkins_password      = var.jenkins_password
    jenkins_config        = file("./scripts/jenkins_config.yaml"),
    aws_access_key        = var.aws_access_key,
    aws_secret_access_key = var.aws_secret_access_key,
    aws_ssh_key           = var.aws_ssh_key,
    aws_secret_region     = var.aws_secret_region,
    aws_secret_services   = var.aws_secret_services,
    aws_ecs_secret        = var.aws_ecs_secret,
    aws_eks_secret        = var.aws_eks_secret,
    terraform_secret      = var.terraform_secret,
    sonarqube_token       = var.sonarqube_token,
    sonarqube_url         = var.sonarqube_route53_url,
    jenkins_url           = var.jenkins_route53_url
    s3_bucket             = var.jenkins_s3_bucket,
    sns_topic             = var.sns_topic,
    user_id               = var.aws_user_id,
    resource_secret_name  = var.resource_secret_name
  })
  s3_config = {
    plugins_list          = file("./scripts/jenkins_plugins.txt"),
    KMS_ENCRYPT           = file("./scripts/kms-encrypt.sh")
    KMS_DECRYPT           = file("./scripts/kms-decrypt.sh")
    users_pipeline_XML    = templatefile("./scripts/jenkins_job.xml", var.user_xml),
    flights_pipeline_XML  = templatefile("./scripts/jenkins_job.xml", var.flights_xml),
    bookings_pipeline_XML = templatefile("./scripts/jenkins_job.xml", var.bookings_xml),
    ecs_deploy_XML        = templatefile("./scripts/jenkins_job.xml", var.ecs_devops_xml),
    eks_deploy_XML        = templatefile("./scripts/jenkins_job.xml", var.eks_devops_xml),
    terraform_XML         = templatefile("./scripts/jenkins_job.xml", var.terraform_xml),
  }
  s3_bucket   = var.jenkins_s3_bucket
  route53_url = var.jenkins_route53_url
}

module "sonarqube" {
  source = "./modules/sonarqube"
  count  = var.enable_sonarqube ? 1 : 0

  vpc_id            = var.vpc_id
  subnet_id         = var.subnet_id
  route53_zone_id   = var.route53_zone_id
  availability_zone = var.availability_zone

  private_ip = var.sonarqube_ip
  user_data = templatefile(var.sonarqube_startup, {
    aws_secret_region = var.aws_secret_region,
    sns_topic         = var.sns_topic,
    user_id           = var.aws_user_id
  })
  s3_config   = {}
  s3_bucket   = var.sonarqube_s3_bucket
  route53_url = var.sonarqube_route53_url
}
