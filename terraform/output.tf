output "bastion_public_ip" { value = module.public.bastion_public_ip }
output "nat_public_ip" { value = module.public.nat_public_ip  }
output "jenkins_public_ip" { value = module.public.jenkins_public_ip  }