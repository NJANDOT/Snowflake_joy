variable "snowflake_organization_name" {
  description = "Snowflake organization name."
  type        = string
}

variable "snowflake_account_name" {
  description = "Snowflake account name (within the organization)."
  type        = string
}

variable "snowflake_user" {
  description = "Snowflake user used by Terraform (key-pair authentication)."
  type        = string
}

variable "snowflake_role" {
  description = "Snowflake role used by Terraform (needs CREATE DATABASE and CREATE INTEGRATION)."
  type        = string
}

variable "snowflake_warehouse" {
  description = "Warehouse used to run the COPY INTO statements."
  type        = string
}

variable "database_name" {
  description = "Database for this environment, e.g. TPCDS_PROD."
  type        = string
}

variable "schema_name" {
  description = "Schema for this environment."
  type        = string
  default     = "TPCDS_PIPELINE_BRONZE"
}

variable "storage_integration_name" {
  description = "Storage integration name (account-level), e.g. S3_INT_PROD."
  type        = string
}

variable "storage_aws_role_arn" {
  description = "ARN of the existing AWS IAM role used by the storage integration."
  type        = string
}

variable "storage_allowed_locations" {
  description = "Locations allowed for the storage integration (end with a slash)."
  type        = list(string)
}

variable "stage_url" {
  description = "URL read by the external stage (end with a slash)."
  type        = string
}

variable "aws_region" {
  description = "AWS region for the AWS provider (IAM is global, any valid region works)."
  type        = string
}

variable "additional_trusted_external_ids" {
  description = "Extra external IDs to keep in the role trust policy (e.g. another integration using the same role)."
  type        = list(string)
  default     = []
}
