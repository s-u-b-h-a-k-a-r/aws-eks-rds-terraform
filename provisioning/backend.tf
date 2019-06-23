terraform {
  backend "s3" {
    bucket = "subhakar-state-bucket"
    key    = "terraform/cluster.tfstate"
    region = "us-west-2"
  }
}
