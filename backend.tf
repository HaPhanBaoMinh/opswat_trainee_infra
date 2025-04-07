terraform {
  backend "s3" {
    bucket = "opswat-trainee-final-project-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
