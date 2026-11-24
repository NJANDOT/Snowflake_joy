output "storage_aws_iam_user_arn" {
  description = "Snowflake IAM user ARN to put in the trust policy of the AWS role."
  value       = module.tpcds_ingestion.storage_aws_iam_user_arn
}

output "storage_aws_external_id" {
  description = "External ID to put in the trust policy of the AWS role."
  value       = module.tpcds_ingestion.storage_aws_external_id
}

output "tables" {
  description = "Tables managed in this environment."
  value       = module.tpcds_ingestion.tables
}
