output "utopia_vpc" { value = aws_vpc.utopia_vpc }

output "vpc_id" { value = aws_vpc.utopia_vpc.id }

output "public_subnet_ids" { value = aws_subnet.public_subnet[*].id }
output "private_subnet_ids" { value = aws_subnet.private_subnet[*].id }

output "public_subnet" { value = aws_subnet.public_subnet }
output "private_subnet" { value = aws_subnet.private_subnet }