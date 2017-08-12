#main.tf
provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "main"
  }
}

resource "aws_vpc" "secondary" {
  cidr_block       = "172.16.0.0/16"
  instance_tenancy = "dedicated"

  tags {
    Name = "secondary"
  }
}

