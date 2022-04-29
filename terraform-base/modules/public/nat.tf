# NAT network
resource "aws_network_interface" "nat_nic" {
  subnet_id   = var.public_subnet[count.index]
  private_ips = [format(var.nat_ip, count.index + 1)]
  count       = length(var.public_subnet)

  security_groups   = [aws_security_group.nat.id]
  source_dest_check = false

  tags = { Name = format("AP_TF_NATNIC_%d", count.index) }
}

resource "aws_instance" "nat" {
  ami           = "ami-001e4628006fd3582"
  instance_type = "t2.micro"
  key_name      = "terraform"
  count         = length(var.public_subnet)

  network_interface {
    network_interface_id = aws_network_interface.nat_nic[count.index].id
    device_index         = 0
  }

  availability_zone = var.availability_zone[count.index]

  tags = {
    Name = format("AP_TF_NAT_%d", count.index)
    EC2-Tag = "Nat"
  }
}

resource "aws_security_group" "nat" {
  name        = "Nat Security Group"
  description = "Security group for the NAT server"
  vpc_id      = var.utopia_vpc_id

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
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8082
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "NAT Security Group" }
}
