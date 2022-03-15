output "vpc_id" { value = module.network.vpc_id }
output "lb_id" { value = module.public.lb_id }
output "public_subnet_ids" { value = module.network.public_subnet_ids }
output "private_subnet_ids" { value = module.network.private_subnet_ids }

resource "aws_secretsmanager_secret" "resource_secrets" {
  name        = var.resource_secret_name
  description = "Resource ARN / IDs deployed with terraform"
}
resource "aws_secretsmanager_secret_version" "resource_secrets" {
  secret_id = aws_secretsmanager_secret.resource_secrets.id
  secret_string = jsonencode({
    VPC_ID             = module.network.utopia_vpc.id,
    ECS_LB_ID          = module.public.lb_id,
    PUBLIC_SUBNET_IDS  = module.network.public_subnet_ids,
    PRIVATE_SUBNET_IDS = module.network.private_subnet_ids
  })
}
