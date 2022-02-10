# Ouput variables
output "jenkins_id" { value = one(aws_instance.jenkins[*].id) }
output "jenkins_public_ip" { value =  one(aws_instance.jenkins[*].public_ip) }