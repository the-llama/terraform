#Variables
variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "aws_region" {
default = "us-east-2"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        us-east-2 = "ami-f1810f86" # ubuntu 14.04 LTS
    }
}

