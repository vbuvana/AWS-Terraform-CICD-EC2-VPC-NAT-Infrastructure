terraform {
  backend "s3" {
    bucket         = "buvana-bucket"         # Retrieved bucket name
    key            = "terraform/state.tfstate" # Path to the state file
    region         = "us-west-2"
    encrypt        = true
    dynamodb_table = "my-terraform-lock-table" # Static table name
  }
}