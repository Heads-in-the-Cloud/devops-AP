# Ouput variables
output "nat_id" { value = aws_instance.nat[*].id }
output "nat_public_ip" { value =  aws_instance.nat[*].public_ip }

output "lb_id" { value = aws_lb.ecs_lb.id }