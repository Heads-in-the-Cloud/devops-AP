variable "cidr_block" { type = string }

variable "public_subnet" { type = list(string) }
variable "private_subnet" { type = list(string) }

variable "nat_id" { type = list(string) }

variable "enable_private" { type = bool }

variable "availability_zone" { type = list(string) }
