terraform {
    backend "s3" {
        bucket = "fuji-tf-state"
        region = "us-west-2"
        key = "us-west-2/terraform.tfstate"
    }
}