variable "name" {
  type= string
}

variable "cidr_vpc" {
  type = list(string)
}

variable "azs_vpc" {
  type = list(string)
}

# variable "vpc_private_subnets" {
#   type = list(string)
# }

# variable "vpc_public_subnets" {
#   type = list(string)
# }

variable "enable_nat_gateway" {
  type = bool
  default = true
}

variable "enable_vpn_gateway" {
  type = bool
  default = false
}

variable "multiple_vpc" {
  type = bool
}

variable "no_vpc" {
  type = number
}
