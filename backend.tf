terraform {
  backend "s3" {
    bucket = "amihai-personal-blog-tf-state"
    key    = "tf-state"
    region = "eu-west-1"
  }
}