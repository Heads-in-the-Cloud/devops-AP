# Sets up the Virtual Private Cloud
resource "aws_vpc" "utopia_vpc" {
  cidr_block = var.cidr_block
  tags       = { Name = "AP_TF_VPC" }
}

resource "aws_internet_gateway" "utopia_gateway" {
  vpc_id = aws_vpc.utopia_vpc.id
  tags   = { Name = "AP_TF_GT" }
}

# Public Subnets
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.utopia_vpc.id
  cidr_block = var.public_subnet
  depends_on = [aws_vpc.utopia_vpc]

  map_public_ip_on_launch = true

  availability_zone = var.availability_zone

  tags = { Name = "AP_TF_PublicSubnet" }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.utopia_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.utopia_gateway.id
  }

  tags = { Name = "AP_TF_BastionRouteTable" }
}
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.utopia_vpc.id
  cidr_block = var.private_subnet
  depends_on = [aws_vpc.utopia_vpc]

  availability_zone = var.availability_zone

  tags = { Name = "AP_TF_PublicSubnet" }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.utopia_vpc.id

  count = var.enable_private ? 1 : 0

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = var.nat_id
  }

  tags = { Name = "AP_TF_JenkinsRouteTable" }
}
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = one(aws_route_table.private_rt.*.id)

  count = var.enable_private ? 1 : 0
}