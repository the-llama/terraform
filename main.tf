#main.tf
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config {
    bucket = "fuji-tf-state"
    key    = "${var.secret_key}"
    region = "us-east-2"
  }
}
#First VPC
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "main"
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

resource "aws_internet_gateway" "default" {
    vpc_id = "${aws_vpc.default.id}"

  #VPC networking
  resource "aws_vpc_peering_connection" "primary2secondary" {
  # Main VPC ID.
  vpc_id = "${aws_vpc.main.id}"

  # AWS Account ID. This can be dynamically queried using the
  # aws_caller_identity data resource.
  # https://www.terraform.io/docs/providers/aws/d/caller_identity.html
  peer_owner_id = "${data.aws_caller_identity.current.account_id}"

  # Secondary VPC ID.
  peer_vpc_id = "${aws_vpc.secondary.id}"

  # Flags that the peering connection should be automatically confirmed. This
  # only works if both VPCs are owned by the same account.
  auto_accept = true
}
