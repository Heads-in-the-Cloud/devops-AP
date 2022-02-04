# sonarqube instance
resource "aws_network_interface" "sonarqube" {
  subnet_id   = var.public_subnet[0]
  private_ips = [var.sonarqube_ip]
  count       = var.enable_sonarqube ? 1 : 0

  security_groups = [one(aws_security_group.sonarqube[*].id)]

  tags = { Name = "AP_TF_SonarQubeNIC" }
}

resource "aws_instance" "sonarqube" {
  # ami           = "ami-002068ed284fb165b"
  ami           = "ami-0cfb83e121665ed23"
  instance_type = "t2.medium"
  key_name      = "terraform"
  count         = var.enable_sonarqube ? 1 : 0

  network_interface {
    network_interface_id = one(aws_network_interface.sonarqube[*].id)
    device_index         = 0
  }

  # user_data            = var.sonarqube_startup
  user_data            = "sudo /opt/sonarqube/bin/linux-x86-64/sonar.sh start"
  iam_instance_profile = aws_iam_instance_profile.sonarqube.name

  availability_zone = var.availability_zone[0]

  depends_on = [
    aws_iam_role_policy.sonarqube
  ]

  tags = { Name = "AP_TF_SonarQube" }
}

resource "aws_security_group" "sonarqube" {
  name        = "SonarQube Security Group"
  description = "Security group for the SonarQube server"
  vpc_id      = var.utopia_vpc_id
  count       = var.enable_sonarqube ? 1 : 0

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 9000
    to_port     = 9000
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

  tags = { Name = "SonarQube Security Group" }
}

# sonarqube IAM Role
resource "aws_iam_role" "sonarqube" {
  name = "sonarqube"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_instance_profile" "sonarqube" {
  role = aws_iam_role.sonarqube.name
}
resource "aws_iam_role_policy" "sonarqube" {
  name = "sonarqube"
  role = aws_iam_role.sonarqube.id
  policy = jsonencode({
    Statement = [{
      Action   = ["s3:*"],
      Effect   = "Allow",
      Resource = "*"
    }, {
      Action  = ["sns:Publish"],
      Effect = "Allow",
      Resource = "*"
    }],
  })
}

# sonarqube route 53 url
resource "aws_route53_record" "sonarqube" {
  zone_id = var.route53_zone_id
  name = var.sonarqube_route53_url
  type = "A"
  ttl = "300"
  records = [ aws_instance.sonarqube[0].public_ip ]
}