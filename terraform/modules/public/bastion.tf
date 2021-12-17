# bastion network
resource "aws_network_interface" "bastion_nic" {
  subnet_id       = var.public_subnet
  private_ips     = [ var.bastion_ip ]

  security_groups = [ aws_security_group.bastion.id ]

  tags            = { Name = "AP_TF_BastionNIC" }
}

resource "aws_instance" "bastion" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  key_name      = "terraform"

  network_interface {
    network_interface_id  = aws_network_interface.bastion_nic.id
    device_index          = 0
  }

  user_data = templatefile("${path.module}/bastion_init.sh", { password = var.vnc_password })

  availability_zone       = "us-east-2a"

  tags = { Name = "AP_TF_Bastion" }
}

resource "aws_security_group" "bastion" {
  name = "Bastion Security Group"
  description = "Security group for the bastion server"
  vpc_id = var.utopia_vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "Bastion Security Group" }
}