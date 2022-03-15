# NAT network
resource "aws_network_interface" "nat_nic" {
  subnet_id       = var.public_subnet[0]
  private_ips     = [ var.nat_ip ]
  count           = var.enable_nat ? 1 : 0

  security_groups = [ one(aws_security_group.nat[*].id) ]
  source_dest_check       = false

  tags            = { Name = "AP_TF_NATNIC" }
}

resource "aws_instance" "nat" {
  ami           = "ami-001e4628006fd3582"
  instance_type = "t2.micro"
  key_name      = "terraform"
  count           = var.enable_nat ? 1 : 0

  network_interface {
    network_interface_id  = one(aws_network_interface.nat_nic[*].id)
    device_index          = 0
  }

  availability_zone       = "us-east-2a"

  tags = { Name = "AP_TF_NAT" }
}

resource "aws_security_group" "nat" {
  name = "Nat Security Group"
  description = "Security group for the NAT server"
  vpc_id = var.utopia_vpc_id
  count           = var.enable_nat ? 1 : 0

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "NAT Security Group" }
}