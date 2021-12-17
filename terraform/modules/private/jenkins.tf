# private network
resource "aws_network_interface" "private_nic" {
  subnet_id       = var.private_subnet
  private_ips     = [ var.jenkins_ip ]

  security_groups = [ aws_security_group.Jenkins.id ]

  tags            = { Name = "AP_TF_JenkinsNIC" }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-002068ed284fb165b"
  instance_type = "t2.micro"
  key_name      = "terraform"

  network_interface {
    network_interface_id = aws_network_interface.private_nic.id
    device_index         = 0
  }

  user_data = file("${path.module}/jenkins_init.sh")
  availability_zone      = "us-east-2a"

  tags = { Name = "AP_TF_Jenkins" }
}

resource "aws_security_group" "Jenkins" {
  name = "Jenkins Security Group"
  description = "Security group for the Jenkins server"
  vpc_id = var.utopia_vpc_id

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
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
    ipv6_cidr_blocks  = ["::/0"]
  }

  tags = { Name = "Jenkins Security Group" }
}