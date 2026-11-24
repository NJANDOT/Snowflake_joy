resource "snowflake_database" "this" {
  name    = var.database_name
  comment = "TPC-DS ingestion (${var.environment})"
}

resource "snowflake_schema" "this" {
  database = snowflake_database.this.name
  name     = var.schema_name
  comment  = "TPC-DS bronze layer (${var.environment})"
}

resource "snowflake_storage_integration_aws" "this" {
  name                      = var.storage_integration_name
  enabled                   = true
  storage_provider          = "S3"
  storage_aws_role_arn      = var.storage_aws_role_arn
  storage_allowed_locations = var.storage_allowed_locations
  comment                   = "TPC-DS external stage access (${var.environment})"
}

resource "snowflake_stage_external_s3" "this" {
  database            = snowflake_database.this.name
  schema              = snowflake_schema.this.name
  name                = var.stage_name
  url                 = var.stage_url
  storage_integration = snowflake_storage_integration_aws.this.name

  lifecycle {
    precondition {
      condition     = anytrue([for location in var.storage_allowed_locations : startswith(var.stage_url, location)])
      error_message = "stage_url must be inside one of storage_allowed_locations, otherwise Snowflake rejects the stage."
    }
  }
}

resource "snowflake_file_format_csv" "this" {
  database                     = snowflake_database.this.name
  schema                       = snowflake_schema.this.name
  name                         = "FF_CSV"
  skip_header                  = 1
  field_optionally_enclosed_by = "\""
}

resource "snowflake_file_format_json" "this" {
  database = snowflake_database.this.name
  schema   = snowflake_schema.this.name
  name     = "FF_JSON"
}

resource "snowflake_file_format_parquet" "this" {
  database = snowflake_database.this.name
  schema   = snowflake_schema.this.name
  name     = "FF_PARQUET"
}
