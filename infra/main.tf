# --- VPC ---
resource "aws_vpc" "goshenignite" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = var.project_name }
}

# --- Public Subnets (2) ---
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.goshenignite.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = { Name = "public-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.goshenignite.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}b"

  tags = { Name = "public-2" }
}

# --- Private Subnet ---
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.goshenignite.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.aws_region}a"

  tags = { Name = "private" }
}

# --- IGW ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.goshenignite.id
  tags   = { Name = "igw" }
}

# --- Public Route Table ---
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.goshenignite.id
  tags   = { Name = "public_RTB" }
}

resource "aws_route" "default_internet" {
  route_table_id         = aws_route_table.public_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate both public subnets
resource "aws_route_table_association" "pub1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rtb.id
}

resource "aws_route_table_association" "pub2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rtb.id
}

# --- Security Group ---
resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "Allow 80, 443, 22"
  vpc_id      = aws_vpc.goshenignite.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH (tighten later)"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound"
  }

  tags = { Name = "public_sg" }
}

# --- Latest Amazon Linux 2023 AMI ---
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# --- EC2 in public subnet using public_sg ---
resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  key_name = var.key_name != "" ? var.key_name : null

  tags = { Name = "${var.project_name}-ec2" }
}
