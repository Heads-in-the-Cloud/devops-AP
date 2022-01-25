# jenkins instance
resource "aws_network_interface" "jenkins" {
  subnet_id   = var.public_subnet
  private_ips = [var.jenkins_ip]
  count       = var.enable_jenkins ? 1 : 0

  security_groups = [one(aws_security_group.jenkins[*].id)]

  tags = { Name = "AP_TF_JenkinsNIC" }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  key_name      = "terraform"
  count         = var.enable_jenkins ? 1 : 0

  network_interface {
    network_interface_id = one(aws_network_interface.jenkins[*].id)
    device_index         = 0
  }

  user_data = var.jenkins_startup

  availability_zone = var.availability_zone

  tags = { Name = "AP_TF_Jenkins" }
}

resource "aws_security_group" "jenkins" {
  name        = "Jenkins Security Group"
  description = "Security group for the Jenkins server"
  vpc_id      = var.utopia_vpc_id
  count       = var.enable_jenkins ? 1 : 0

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8082
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "icmp"
    from_port   = -1
    to_port     = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "Jenkins Security Group" }
}
