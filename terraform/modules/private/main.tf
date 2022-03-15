# Security Groups
resource "aws_security_group" "ecs_utopia" {
  name        = "ECS Security Group"
  description = "Security group for ECS"
  vpc_id      = var.utopia_vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [format("%s%s", var.bastion_ip, "/32")]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8082
    cidr_blocks = [format("%s%s", var.bastion_ip, "/32")]
  }
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = [format("%s%s", var.bastion_ip, "/32")]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "AP_TF_ECS_SG" }
}