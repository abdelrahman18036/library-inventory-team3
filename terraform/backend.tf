terraform {
  backend "s3" {
    bucket = "terraformteam3"
    key    = "state/terraform.tfstate"
    region = "us-west-1"
  }
}
