variable "region" {
  default = "eu-west-3"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"  # CIDR for public subnet 1
}

variable "public_subnet_2_cidr" {
  default = "10.0.2.0/24"  # CIDR for public subnet 2
}

variable "private_subnet_cidr" {
  default = "10.0.3.0/24"
}

variable "public_subnet_1_az" {
  default = "eu-west-3a" 
}

variable "public_subnet_2_az" {
  default = "eu-west-3b"
}

variable "private_subnet_az" {
  default = "eu-west-3a"
}

variable "instance_type" {
  description = "EC2 Instance type"
  default     = "t3.micro"
}


variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  default     = "ami-09be70e689bddcef5" 
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  default     = "paris"  
}
