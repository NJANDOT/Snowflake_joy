terraform {
  required_version = ">= 1.7.0, < 2.0"

  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake"
      version = "~> 2.23"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.14"
    }
  }

  # Remote state placeholder (kept commented on purpose).
  # Uncomment and fill in once the state location is decided.
  # backend "s3" {
  #   bucket         = "<STATE_BUCKET>"
  #   key            = "snowflake/tpcds/dev/terraform.tfstate"
  #   region         = "<STATE_REGION>"
  #   dynamodb_table = "<STATE_LOCK_TABLE>"
  #   encrypt        = true
  # }
}

provider "snowflake" {
  organization_name      = var.snowflake_organization_name
  account_name           = var.snowflake_account_name
  user                   = var.snowflake_user
  role                   = var.snowflake_role
  warehouse              = var.snowflake_warehouse
  authenticator          = "SNOWFLAKE_JWT"
  private_key            = file(var.private_key)
  private_key_passphrase = var.private_key_passphrase
}

# AWS: only used to manage the trust policy of the existing IAM role.
# Credentials are NOT in the code: they come from the standard AWS chain
# (e.g. $env:AWS_PROFILE, `aws sso login`, or AWS_ACCESS_KEY_ID/AWS_SECRET_ACCESS_KEY).
# allowed_account_ids stops Terraform if the credentials point to another account.
provider "aws" {
  region              = var.aws_region
  allowed_account_ids = [local.aws_account_id]
}

locals {
  aws_account_id = regex("^arn:aws:iam::([0-9]{12}):role/", var.storage_aws_role_arn)[0]
}
