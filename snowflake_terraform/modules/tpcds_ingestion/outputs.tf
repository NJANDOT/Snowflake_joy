output "database_name" {
  description = "Database created for this environment."
  value       = snowflake_database.this.name
}

output "schema_name" {
  description = "Schema created for this environment."
  value       = snowflake_schema.this.name
}

output "storage_aws_iam_user_arn" {
  description = "Snowflake IAM user ARN trusted by the AWS role (set automatically in the trust policy)."
  value       = snowflake_storage_integration_aws.this.describe_output[0].iam_user_arn
}

output "storage_aws_external_id" {
  description = "External ID trusted by the AWS role (set automatically in the trust policy)."
  value       = snowflake_storage_integration_aws.this.describe_output[0].external_id
}

output "aws_role_name" {
  description = "Name of the AWS IAM role whose trust policy is managed by this module."
  value       = aws_iam_role.snowflake_access.name
}

output "tables" {
  description = "Names of the tables managed by this module."
  value       = sort([for name in keys(local.tables) : upper(name)])
}
