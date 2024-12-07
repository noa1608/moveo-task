variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_a" {
  default = "10.0.9.0/24"
}

variable "public_subnet_cidr_b" {
  default = "10.0.10.0/24" 
}

variable "private_subnet_cidr" {
  default = "10.0.11.0/24"
}

variable "availability_zone_a" {
  default = "us-east-1a"
}

variable "availability_zone_b" {
  default = "us-east-1b"
}
