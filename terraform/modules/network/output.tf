output "utopia_vpc" { value = aws_vpc.utopia_vpc }

output "public_subnet" { value = aws_subnet.public_subnet }
output "private_subnet" { value = aws_subnet.private_subnet }