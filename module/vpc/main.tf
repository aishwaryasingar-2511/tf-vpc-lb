#----------VPC---------#
resource "aws_vpc" "ownvpc" {
  cidr_block       = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = merge(var.tags, {Name = format("%s-%s-vpc",var.appname,var.env)})
}
#------------IGW---------#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.ownvpc.id

  tags = merge(var.tags, {Name = format("%s-%s-igw",var.appname,var.env)})
}
#------ELASTIC IP--------#
resource "aws_eip" "my-eip" {
  vpc      = true
  tags = merge(var.tags, {Name = format("%s-%s-eip",var.appname,var.env)})
}
#--------------NAT-gateway----------#
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.my-eip.id
  subnet_id     = aws_subnet.public[0].id
  depends_on = [aws_internet_gateway.igw]
  tags = merge(var.tags, {Name = format("%s-%s-nat-gw",var.appname,var.env)})
}
#-------------Public-subnet-----------#
resource "aws_subnet" "public" {
  count = length(var.public_cidr_block)
  vpc_id     = aws_vpc.ownvpc.id
  cidr_block = var.public_cidr_block[count.index]
  availability_zone = element(var.azs, count.index)
  map_public_ip_on_launch = "true"

  tags = merge(var.tags, {Name = format("%s-%s-public_subnet",var.appname,var.env)})
}
#--------------private-subnet-------------#
resource "aws_subnet" "private" {
  count = length(var.private_cidr_block)
  vpc_id     = aws_vpc.ownvpc.id
  cidr_block = var.private_cidr_block[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, {Name = format("%s-%s-private_subnet",var.appname,var.env)})
}
#----------------Public-Route-Table--------------#
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.ownvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, {Name = format("%s-%s-public-rt",var.appname,var.env)})
}
#-------------Private-Route-Table-----------------#
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.ownvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-gw.id
    }
  tags = merge(var.tags, {Name = format("%s-%s-private-rt",var.appname,var.env)})
}
  #---------------Public-subnet-association-----------------#
  resource "aws_route_table_association" "public-s-a" {
   count = length(var.public_cidr_block)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt.id
}
#-------------------Private-subnet-association-------------#
resource "aws_route_table_association" "private-s-a" {
   count = length(var.private_cidr_block)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt.id
}
#-----------Security-group-----------#
resource "aws_security_group" "task-sg" {
  name        = "task-sg"
  description = "my-sg inbound traffic"
  vpc_id      = aws_vpc.ownvpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "task-sg"
  }
}