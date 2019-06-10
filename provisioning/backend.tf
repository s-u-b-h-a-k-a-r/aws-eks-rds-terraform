terraform {
  backend "s3" {
    bucket = "your-bucket-name"
    key    = "terraform/your.tfstate"
    region = "us-west-2"
  }
}
