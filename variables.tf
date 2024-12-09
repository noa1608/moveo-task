variable "region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  default = "10.0.1.0/24"  
}

variable "public_subnet_2_cidr" {
  default = "10.0.2.0/24"  
}

variable "private_subnet_cidr" {
  default = "10.0.3.0/24"
}

variable "public_subnet_1_az" {
  default = "us-west-2a" 
}

variable "public_subnet_2_az" {
  default = "us-west-2b"
}

variable "private_subnet_az" {
  default = "us-west-2a"
}

variable "instance_type" {
  description = "EC2 Instance type"
  default     = "t3.micro"
}


variable "ami_id" {
  description = "AMI ID for Ubuntu 22.04 LTS"
  default     = "ami-05d38da78ce859165" 
}

variable "key_name" {
  description = "Key pair name for EC2 access"
  default     = "moveo"  
}
