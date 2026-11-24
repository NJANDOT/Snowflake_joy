module "tpcds_ingestion" {
  source = "../../modules/tpcds_ingestion"

  environment               = "dev"
  database_name             = var.database_name
  schema_name               = var.schema_name
  storage_integration_name  = var.storage_integration_name
  storage_aws_role_arn      = var.storage_aws_role_arn
  storage_allowed_locations = var.storage_allowed_locations
  stage_url                 = var.stage_url

  additional_trusted_external_ids = var.additional_trusted_external_ids
}

# The IAM role already exists: adopt it on the first apply instead of creating it.
# After the first apply this block is a no-op.
import {
  to = module.tpcds_ingestion.aws_iam_role.snowflake_access
  id = element(reverse(split("/", var.storage_aws_role_arn)), 0)
}
