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
}
