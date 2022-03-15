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
  cidr_block = var.public_subnet[count.index]
  depends_on = [aws_vpc.utopia_vpc]
  count      = length(var.public_subnet)

  map_public_ip_on_launch = true

  availability_zone = var.availability_zone[count.index]

  tags = { Name = format("AP_TF_PublicSubnet_%d", count.index) }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.utopia_vpc.id
  count  = length(var.public_subnet)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.utopia_gateway.id
  }

  tags = { Name = format("AP_TF_PublicRT_%d", count.index) }
}
resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt[count.index].id

  count = length(var.public_subnet)
}

# Private Subnets
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.utopia_vpc.id
  cidr_block = var.private_subnet[count.index]
  depends_on = [aws_vpc.utopia_vpc]
  count  = length(var.private_subnet)

  availability_zone = var.availability_zone[count.index]

  tags = { Name = format("AP_TF_PrivateSubnet_%d", count.index) }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.utopia_vpc.id

  count = length(var.private_subnet)

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = var.nat_id[count.index]
  }

  tags = { Name = format("AP_TF_PrivateRT_%d", count.index) }
}
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt[count.index].id

  count = length(var.private_subnet)
}
