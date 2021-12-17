# Ouput variables
output "bastion_ip" { value = var.bastion_ip }
output "nat_id" { value = aws_instance.nat.id }

output "bastion_public_ip" { value = aws_instance.bastion.public_ip }
output "nat_public_id" { value = aws_instance.nat.public_ip  }