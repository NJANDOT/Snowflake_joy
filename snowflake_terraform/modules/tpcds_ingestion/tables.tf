# Tables are created with snowflake_execute because snowflake_table (Preview)
# cannot create TRANSIENT tables.
#
# The revert statement is a deliberate no-op ("SELECT 1"): a destroy or a change
# of the execute statement must never drop a table or its data. Schema changes
# on an existing table must be done with an ALTER TABLE outside of Terraform.
resource "snowflake_execute" "table" {
  for_each = local.tables

  execute = <<-SQL
    CREATE TRANSIENT TABLE IF NOT EXISTS ${local.schema_fqn}.${upper(each.key)} (
      ${join(",\n      ", each.value.columns)}
    )
  SQL
  revert  = "SELECT 1"

  lifecycle {
    precondition {
      condition     = contains(["csv", "json", "parquet"], each.value.format)
      error_message = "Table ${each.key}: format must be one of csv, json, parquet (got \"${each.value.format}\")."
    }
  }
}

# COPY INTO only loads files that Snowflake has not already loaded (load
# metadata is kept 64 days). To force a reload: terraform taint
# 'module.<name>.snowflake_execute.copy_into["<table>"]'.
# The revert is a no-op: never truncate loaded data on destroy.
resource "snowflake_execute" "copy_into" {
  for_each = local.tables

  execute = <<-SQL
    COPY INTO ${local.schema_fqn}.${upper(each.key)}
    FROM @${local.schema_fqn}.${snowflake_stage_external_s3.this.name}/${each.key}.${each.value.format}
    FILE_FORMAT = (FORMAT_NAME = '${local.schema_fqn}.${local.file_format_names[each.value.format]}')
    ${each.value.format == "csv" ? "" : "MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE"}
    ON_ERROR = ABORT_STATEMENT
  SQL
  revert  = "SELECT 1"

  # The trust policy must be in place (and propagated) before Snowflake reads the files.
  depends_on = [snowflake_execute.table, time_sleep.iam_propagation]
}

check "table_count" {
  assert {
    condition     = length(local.tables) == 24
    error_message = "tables.yaml must define the 24 TPC-DS tables (found ${length(local.tables)})."
  }
}

locals {
  tables     = yamldecode(file("${path.module}/tables.yaml"))
  schema_fqn = "${snowflake_database.this.name}.${snowflake_schema.this.name}"

  file_format_names = {
    csv     = snowflake_file_format_csv.this.name
    json    = snowflake_file_format_json.this.name
    parquet = snowflake_file_format_parquet.this.name
  }
}
