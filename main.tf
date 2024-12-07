resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = { Name = "assignment-vpc" }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "Main NAT Gateway" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_a
  availability_zone       = var.availability_zone_a
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_b
  availability_zone       = var.availability_zone_b
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone_b
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"  # Allow all outbound traffic to the internet
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_a_association" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_association" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "nginx_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private" {
  vpc_id = aws_vpc.main.id
  ingress {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [aws_security_group.nginx_sg.id]  
      description = "Allow traffic from public SG"
    }
  tags = { Name = "Private Security Group" }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.nginx_sg.id]  # Allow traffic only from the ALB
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Replace with your trusted IP
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "EC2 Security Group" }
}

resource "aws_instance" "nginx" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.ec2_sg.id]

  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    service docker start
    docker run -d -p 80:80 noa1608/nginx-custom
  EOF
  tags = { Name = "nginx-instance" }
}

resource "aws_lb" "nginx_lb" {
  name               = "nginx-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = [aws_subnet.public_a.id, aws_subnet.public_b.id]

}

resource "aws_lb_target_group" "nginx_tg" {
  name     = "nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
 # health_check {
 #   path = "/"
 #   interval = 30
 #   timeout  = 5
 #   healthy_threshold = 3
  #  unhealthy_threshold = 3
 # }
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "nginx_tg_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}

resource "aws_instance" "bastion" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_a.id
  security_groups = [aws_security_group.ec2_sg.id]

  tags = { Name = "Bastion Host" }
}

output "nginx_public_ip" {
  value = aws_instance.nginx.public_ip
}

output "nginx_lb_dns" {
  value = aws_lb.nginx_lb.dns_name
}
