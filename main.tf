###################################################################################
# This file describes the vpc, internet gateway, nat gateway and route tables
###################################################################################

resource "aws_vpc" "vpc" {
    cidr_block              = var.vpc_cidr
    enable_dns_hostnames    = true
    enable_dns_support      = true
    tags = {
      Name = "${var.domain}-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id                  = aws_vpc.vpc.id
    tags = {
      Name = "${var.domain}-igw"
    }
}

resource "aws_nat_gateway" "ngw" {
    allocation_id           = aws_eip.nateip.id
    subnet_id               = aws_subnet.public_subnet_1.id
    depends_on              = [ aws_internet_gateway.igw ]
    tags = {
      Name = "${var.domain}-ngw"
    }
}

resource "aws_eip" "nateip" {
    domain                  = "vpc"
    tags = {
      Name = "${var.domain}-eip"
    }
}
  
resource "aws_subnet" "private_subnet_1" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.private_subnet_1
    availability_zone       = var.availibilty_zone_1
    tags = {
      Name = "${var.domain}-private-subnet-1"
    }
}

resource "aws_subnet" "private_subnet_2" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.private_subnet_2
    availability_zone       = var.availibilty_zone_2
    tags = {
      Name = "${var.domain}-private-subnet-2"
    }
}

resource "aws_subnet" "public_subnet_1" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnet_1
    availability_zone       = var.availibilty_zone_1
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.domain}-public-subnet-1"
    }
}

resource "aws_subnet" "public_subnet_2" {
    vpc_id                  = aws_vpc.vpc.id
    cidr_block              = var.public_subnet_2
    availability_zone       = var.availibilty_zone_2
    map_public_ip_on_launch = true
    tags = {
      Name = "${var.domain}-public-subnet-2"
    }
}

resource "aws_route_table" "public" {
    vpc_id                  = aws_vpc.vpc.id
    tags = {
      Name = "${var.domain}-public-route-table"
    }
}

resource "aws_route" "public" {
    route_table_id          = aws_route_table.public.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public1" {
    subnet_id               = aws_subnet.public_subnet_1.id
    route_table_id          = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
    subnet_id               = aws_subnet.public_subnet_2.id
    route_table_id          = aws_route_table.public.id
}

resource "aws_route_table" "private" {
    vpc_id                  = aws_vpc.vpc.id
    tags = {
      Name = "${var.domain}-private-route-table"
    }
}
  
resource "aws_route" "private" {
    route_table_id          = aws_route_table.private.id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.ngw.id
}

resource "aws_route_table_association" "private1" {
    subnet_id               = aws_subnet.private_subnet_1.id
    route_table_id          = aws_route_table.private.id
}

resource "aws_route_table_association" "private2" {
    subnet_id               = aws_subnet.private_subnet_2.id
    route_table_id          = aws_route_table.private.id
}
