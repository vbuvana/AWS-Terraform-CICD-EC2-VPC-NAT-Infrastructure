terraform {
  backend "s3" {
    bucket         = var.bucket_name # S3 bucket where the Terraform backend state will be stored        # Retrieved bucket name
    key            = "terraform/state.tfstate" # Path to the state file
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lock-table" # Static table name
  }
}