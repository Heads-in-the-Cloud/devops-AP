# Ouput variables
output "bastion_ip" { value = var.bastion_ip }
output "nat_id" { value = one(aws_instance.nat[*].id) }
output "jenkins_id" { value = one(aws_instance.jenkins[*].id) }

output "bastion_public_ip" { value = one(aws_instance.bastion[*].public_ip) }
output "nat_public_ip" { value =  one(aws_instance.nat[*].public_ip) }
output "jenkins_public_ip" { value =  one(aws_instance.jenkins[*].public_ip) }