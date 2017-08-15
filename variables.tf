variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "us-east-1"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-1 = "ami-a7aa8ac2" # ubuntu 16.04 LTS
    }
}

variable "primary_vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.1.0.0/16"
}

variable "secondary_vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.2.0.0/16"
}

variable "primary_public_subnet_cidr" {
    description = "CIDR for the Primary Public Subnet"
    default = "172.16.1.0/24"
}

variable "secondary_public_subnet_cidr" {
    description = "CIDR for the Secondary Public Subnet"
    default = "172.16.2.0/24"
}

variable "primary_private_subnet_cidr" {
    description = "CIDR for the primary Private Subnet"
    default = "10.1.1.0/24"
}

variable "secondary_private_subnet_cidr" {
    description = "CIDR for the secondary Private Subnet"
    default = "10.2.2.0/24"
}