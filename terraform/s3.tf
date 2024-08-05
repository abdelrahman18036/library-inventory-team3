terraform {
  backend "s3" {
    bucket = "terrateam3"
    key    = "state/terraform.tfstate"
    region = "us-west-2"
  }
}
