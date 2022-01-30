# jenkins instance
resource "aws_network_interface" "jenkins" {
  subnet_id   = var.public_subnet[0]
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

  user_data            = var.jenkins_startup
  iam_instance_profile = aws_iam_instance_profile.jenkins.name

  availability_zone = var.availability_zone[0]

  depends_on = [
    aws_iam_role_policy.jenkins
  ]

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

# jenkins IAM Role
resource "aws_iam_role" "jenkins" {
  name = "jenkins"
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
resource "aws_iam_instance_profile" "jenkins" {
  role = aws_iam_role.jenkins.name
}
resource "aws_iam_role_policy" "jenkins" {
  name = "jenkins"
  role = aws_iam_role.jenkins.id
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

# jenkins config S3 Bucket
resource "aws_s3_bucket" "jenkins_config" {
  bucket = "tf-ap-jenkins-config"
  acl    = "private"
}
resource "aws_s3_bucket_object" "jenkins_jobs" {
  for_each = var.jenkins_config
  key      = each.key
  bucket   = aws_s3_bucket.jenkins_config.id
  content  = each.value
}
