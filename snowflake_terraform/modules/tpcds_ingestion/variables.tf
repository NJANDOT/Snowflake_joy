variable "environment" {
  description = "Environment name (dev or prod). Used for labels and comments."
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "environment must be either \"dev\" or \"prod\"."
  }
}

variable "database_name" {
  description = "Snowflake database name (UPPERCASE so it matches unquoted SQL identifiers), e.g. TPCDS_DEV."
  type        = string

  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]*$", var.database_name))
    error_message = "database_name must be UPPERCASE letters, digits or underscores, and start with a letter."
  }
}

variable "schema_name" {
  description = "Snowflake schema that holds the tables, stage and file formats."
  type        = string
  default     = "TPCDS_PIPELINE_BRONZE"

  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]*$", var.schema_name))
    error_message = "schema_name must be UPPERCASE letters, digits or underscores, and start with a letter."
  }
}

variable "storage_integration_name" {
  description = "Account-level storage integration name. Must be unique per environment, e.g. S3_INT_DEV."
  type        = string

  validation {
    condition     = can(regex("^[A-Z][A-Z0-9_]*$", var.storage_integration_name))
    error_message = "storage_integration_name must be UPPERCASE letters, digits or underscores, and start with a letter."
  }
}

variable "storage_aws_role_arn" {
  description = "ARN of the existing AWS IAM role Snowflake assumes to read the data files."
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:role/.+$", var.storage_aws_role_arn))
    error_message = "storage_aws_role_arn must look like arn:aws:iam::<12-digit account id>:role/<name>."
  }
}

variable "storage_allowed_locations" {
  description = "Locations the storage integration is allowed to access (must end with a slash)."
  type        = list(string)

  validation {
    condition     = length(var.storage_allowed_locations) > 0 && alltrue([for l in var.storage_allowed_locations : can(regex("^s3://.+/$", l))])
    error_message = "Each storage_allowed_locations entry must start with s3:// and end with a slash."
  }
}

variable "additional_trusted_external_ids" {
  description = "Extra external IDs kept in the role trust policy (e.g. another storage integration of the same Snowflake account that uses this role)."
  type        = list(string)
  default     = []
}

variable "stage_name" {
  description = "External stage name."
  type        = string
  default     = "EXT_STAGE_TPCDS"
}

variable "stage_url" {
  description = "URL of the existing location read by the external stage (must end with a slash)."
  type        = string

  validation {
    condition     = can(regex("^s3://.+/$", var.stage_url))
    error_message = "stage_url must start with s3:// and end with a slash."
  }
}
