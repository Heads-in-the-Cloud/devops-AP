# bastion network
resource "aws_network_interface" "bastion" {
  subnet_id   = var.public_subnet[count.index]
  private_ips = [format(var.bastion_ip, count.index + 1)]
  count       = var.enable_bastion ? length(var.public_subnet) : 0

  security_groups = [one(aws_security_group.bastion[*].id)]

  tags = { Name = format("AP_TF_BastionNIC_%d", count.index) }
}

resource "aws_instance" "bastion" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  key_name      = "terraform"
  count         = var.enable_bastion ? length(var.public_subnet) : 0

  network_interface {
    network_interface_id = aws_network_interface.bastion[count.index].id
    device_index         = 0
  }

  user_data         = var.bastion_init
  availability_zone = var.availability_zone[count.index]

  tags = { Name = format("AP_TF_Bastion_%d", count.index) }
}

resource "aws_security_group" "bastion" {
  name        = "Bastion Security Group"
  description = "Security group for the bastion server"
  vpc_id      = var.utopia_vpc_id
  count       = var.enable_bastion ? 1 : 0

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "Bastion Security Group" }
}
