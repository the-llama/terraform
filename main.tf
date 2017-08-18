#main.tf
provider "aws" {
	region = "us-east-1"
	profile = "terraform-user"
	shared_credentials_file = "C://Users//Mark//.aws//credentials"
	
}

#First VPC
	resource "aws_vpc" "primary" {
	cidr_block       = "${var.primary_vpc_cidr}"
	instance_tenancy = "dedicated"

  tags {
    Name = "primary"
  }
  default_security_group_id = "0011"
}

#Secondary VPC
	resource "aws_vpc" "secondary" {
	cidr_block       = "${var.secondary_vpc_cidr}"
	instance_tenancy = "dedicated"
  
  tags {
    Name = "secondary"
  }
  default_security_group_id = "0011"
}

resource "aws_internet_gateway" "primary-nat-gateway" {
    vpc_id = "${aws_vpc.primary.id}"
}
resource "aws_internet_gateway" "secondary-nat-gateway" {
    vpc_id = "${aws_vpc.secondary.id}"
}
resource "aws_security_group" "nat" {
    name = "vpc_nat"
    description = "Allow traffic to pass from the private subnet to the internet"

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["${var.primary_private_subnet_cidr}"]
		cidr_blocks = ["${var.secondary_private_subnet_cidr}"]
    }
    ingress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["${var.primary_private_subnet_cidr}"]
		cidr_blocks = ["${var.secondary_private_subnet_cidr}"]
    }
	egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
   }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}
}

resource "aws_security_group" "http_rules" {
	name = "http_rules"
	description = "Allow inbound HTTP traffic"
	id = "0011"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["${var.primary_private_subnet_cidr}"]
		cidr_blocks = ["${var.secondary_private_subnet_cidr}"]
		}

	ingress {
		from_port = 443
		to_port = 443 
		protocol = "tcp"
		cidr_blocks = ["${var.primary_private_subnet_cidr}"]
		cidr_blocks = ["${var.secondary_private_subnet_cidr}"]
		}
}
	
  #VPC networking
  resource "aws_vpc_peering_connection" "primary2secondary" {
  # Primary VPC ID.
  vpc_id = "${aws_vpc.primary.id}"

  # Secondary VPC ID.
  peer_vpc_id = "${aws_vpc.secondary.id}"

  # Flags that the peering connection should be automatically confirmed. This
  # only works if both VPCs are owned by the same account.
  auto_accept = true
}
  #Routing between VPCs
  resource "aws_route" "primary2secondary" {
  # ID of VPC 1 main route table.
  route_table_id = "${aws_vpc.primary.main_route_table_id}"

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "${aws_vpc.secondary.cidr_block}"

  # ID of VPC peering connection.
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}
  
  resource "aws_route" "secondary2primary" {
  # ID of VPC 2 main route table.
  route_table_id = "${aws_vpc.secondary.main_route_table_id}"

  # CIDR block / IP range for VPC 2.
  destination_cidr_block = "${aws_vpc.secondary.cidr_block}"

  # ID of VPC peering connection.
  vpc_peering_connection_id = "${aws_vpc_peering_connection.primary2secondary.id}"
}

resource "aws_instance" "nat" {
    ami = "ami-bb0f74ac" # this is a special ami preconfigured to do NAT
    availability_zone = "us-east-1a"
    instance_type = "m1.small"
    vpc_security_group_ids = ["${aws_security_group.nat.id}"]
    subnet_id = "${var.primary_public_subnet_cidr }"
    associate_public_ip_address = true
    source_dest_check = false

	tags {
	name = "VPC NAT"
	}
}
