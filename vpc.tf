# Create VPC
resource "aws_vpc" "main" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"
    enable_classiclink = "false"
    instance_tenancy = "default"

    tags = {
      Name = "AFERRANC-CCF-vpc"
    }
}

# Create private subnet 1
resource "aws_subnet" "private-subnet1" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.10.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1a"

    tags = {
      Name = "AFERRANC-CCF-private-subnet1"
    }
}

# Create private subnet 2
resource "aws_subnet" "private-subnet2" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.10.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1c"

    tags = {
      Name = "AFERRANC-CCF-private-subnet2"
    }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "AFERRANC-CCF-igw"
  }
}

# Create Route Table
resource "aws_default_route_table" "rt" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "AFERRANC-CCF-rt"
  }
}

# Associate subnets
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.private-subnet1.id
  route_table_id = aws_default_route_table.rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.private-subnet2.id
  route_table_id = aws_default_route_table.rt.id
}

