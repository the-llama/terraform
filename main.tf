#main.tf
	provider "aws" {
	region = "us-west-2"
	shared_credentials_file = "~//.aws//credentials"
	#profile = default
	
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "fuji-tf-state"
    #key    = "${var.aws_secret_key}"
    region = "us-west-2"
  }
}
#First VPC
resource "aws_vpc" "primary" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "primary"
  }
}

#Secondary VPC
resource "aws_vpc" "secondary" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "dedicated"
  
  tags {
    Name = "secondary"
  }
}

resource "aws_internet_gateway" "primary-nat-gateway" {
    vpc_id = "${aws_vpc.primary.id}"
}
resource "aws_internet_gateway" "secondary-nat-gateway" {
    vpc_id = "${aws_vpc.secondary.id}"
}

resource "aws_security_group" "http_rules" {
	name = "http_rules"
	description = "Allow inbound HTTP traffic"
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		}

	ingress {
		from_port = 443
		to_port = 443 
		protocol = "tcp"
		}
	vpc_id = "${aws_vpc.primary.id}"
	vpc_id = "${aws_vpc.secondary.id}"
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

