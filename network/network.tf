/* Module for creating base networking objects */



/* Data Sources */
data "aws_availability_zones" "available" {
  state = "available"
}

/* Resources */
resource "aws_vpc" "sydney-vpc" {
  cidr_block = var.vpc_cidr_block

  tags = local.common_tags
}

resource "aws_internet_gateway" "sydney-igw" {
  vpc_id = aws_vpc.sydney-vpc.id

  tags = local.common_tags
}

resource "aws_subnet" "public_subnets" {
  vpc_id                  = aws_vpc.sydney-vpc.id
  map_public_ip_on_launch = "true"

  for_each = {
    public_1 = {
      cidr = "10.1.101.0/24"
      az   = data.aws_availability_zones.available.names[0]
    }
    public_2 = {
      cidr = "10.1.102.0/24"
      az   = data.aws_availability_zones.available.names[0]
    }
  }

  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]

  tags = merge(local.common_tags, { Name = "Subnet-${each.key}"})
}

resource "aws_subnet" "sydney-private-subnet1" {
  cidr_block = var.vpc_private_subnet_cidr_block
  vpc_id     = aws_vpc.sydney-vpc.id

  tags = local.common_tags
}

resource "aws_route_table" "sydney-rtb" {
  vpc_id = aws_vpc.sydney-vpc.id

  tags = local.common_tags
}

resource "aws_route" "sydney-ipv4-default-rt" {
  route_table_id         = aws_route_table.sydney-rtb.id
  destination_cidr_block = local.default_ipv4_route
  gateway_id             = aws_internet_gateway.sydney-igw.id
}

resource "aws_route_table_association" "sydney-public-subnet-az1-assoc" {
  subnet_id      = aws_subnet.public_subnets["public_1"].id
  route_table_id = aws_route_table.sydney-rtb.id
}

resource "aws_route_table_association" "sydney-public-subnet-az2-assoc" {
  subnet_id      = aws_subnet.public_subnets["public_2"].id
  route_table_id = aws_route_table.sydney-rtb.id
}

resource "aws_security_group" "sydney-public-web-sg" {
  name   = "public web security groups"
  vpc_id = aws_vpc.sydney-vpc.id
}

resource "aws_security_group_rule" "sydney-public-web-http-in-rule" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sydney-public-web-sg.id
}

resource "aws_security_group_rule" "sydney-public-web-ssh-in-rule" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sydney-public-web-sg.id
}

resource "aws_security_group_rule" "sydney-public-web-all-out-rule" {
  type              = "egress"
  protocol          = "all"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sydney-public-web-sg.id
}

resource "random_integer" "random" {
  min = 10000
  max = 99999
}
