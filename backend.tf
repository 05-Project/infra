terraform {
  backend "s3" {
    bucket = "project05-sesac"
    key = "s3-tfstate_storage/terraform.tfstate"
    region = "ap-northeast-2"
  }
}