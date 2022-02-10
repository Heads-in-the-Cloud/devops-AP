resource "aws_lb" "ecs_lb" {
  name               = "ap-utopia-load-balancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in var.public_subnet : subnet]

  tags = { Name = "AP_ECS_LB" }
}

resource "aws_route53_record" "utopia_record" {
  zone_id     = var.route53_zone_id
  name        = var.ecs_record
  type        = "CNAME"
  ttl         = "30"
  records     = [aws_lb.ecs_lb.dns_name]
}