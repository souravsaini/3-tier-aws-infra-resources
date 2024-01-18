terraform {
  backend "s3" {
    bucket         = "aws-resources-terraform-state-bucket"
    key            = "us-east-1/app/terraform.tfstate"
    region         = "us-east-1"  
    dynamodb_table = "terraform-terraform-state-dynamodb"
  }
}
