# snowflake_terraform

Terraform project for the TPC-DS ingestion in Snowflake. It reproduces
`ingestion_creation/setup_and_load.sql` for two environments: `dev` and `prod`.
The bucket that holds the data files already exists and is not managed here.
`ingestion_creation/generate.py` stays outside of Terraform.

## Layout

```
modules/tpcds_ingestion/   shared module
  main.tf       database, schema, storage integration, stage, file formats
  aws_trust.tf  trust policy of the existing AWS IAM role (AWS provider)
  tables.tf     24 transient tables + 24 COPY INTO (for_each on tables.yaml)
  tables.yaml   table definitions (format + columns)
envs/dev/       root module DEV  (own state, own tfvars)
envs/prod/      root module PROD (own state, own tfvars)
```

## What is created

| Object | Terraform resource |
|---|---|
| Database, schema | `snowflake_database`, `snowflake_schema` |
| Storage integration | `snowflake_storage_integration_aws` |
| External stage | `snowflake_stage_external_s3` |
| File formats `FF_CSV`, `FF_JSON`, `FF_PARQUET` | `snowflake_file_format_csv`, `_json`, `_parquet` |
| 24 transient tables | `snowflake_execute` (`CREATE TRANSIENT TABLE IF NOT EXISTS`) |
| 24 `COPY INTO` | `snowflake_execute` |
| Trust policy of the existing IAM role | `aws_iam_role` (imported, trust policy only) |

Tables use `snowflake_execute` because `snowflake_table` is a Preview resource and
cannot create `TRANSIENT` tables.

## Usage

1. Fill in the placeholders:
   ```powershell
   Copy-Item envs\dev\terraform.tfvars.example envs\dev\terraform.tfvars
   ```
2. Provide the private key through the environment (never in the code):
   ```powershell
   $env:SNOWFLAKE_PRIVATE_KEY = Get-Content -Raw <path-to-private-key.p8>
   ```
3. Plan (never apply without a human review):
   ```powershell
   terraform -chdir=envs/dev init
   terraform -chdir=envs/dev plan
   ```
4. Provide AWS credentials for the account of `storage_aws_role_arn` (see below).
   The trust policy of the role is then updated automatically on every apply.
5. The remote state backend is a commented block in `envs/<env>/providers.tf`.

## AWS trust policy (automated)

Snowflake reads the bucket by assuming the existing IAM role with its account-level IAM
user and the external ID of the storage integration. `modules/tpcds_ingestion/aws_trust.tf`
writes these two values into the trust policy of the role, so a new or recreated
integration needs no manual step. A 30 s wait lets IAM propagate the change before the
COPY INTO statements run.

- **Credentials**: standard AWS chain, never in the code. Locally, for example
  `$env:AWS_PROFILE = '<profile>'` (or `aws sso login --profile <profile>`).
  The identity needs `iam:GetRole` and `iam:UpdateAssumeRolePolicy` on the role
  (plus `iam:ListRolePolicies` / `iam:ListAttachedRolePolicies` for the refresh).
  In CI, prefer GitHub OIDC with a dedicated role.
- **Account guard**: `allowed_account_ids` makes Terraform stop if the credentials
  belong to another account than the one in `storage_aws_role_arn`.
- **Import**: the role already exists. The `import` block in `envs/<env>/main.tf` adopts
  it on the first apply; afterwards the block does nothing.
- **Scope**: only the trust policy is managed. The permission policies of the role
  (S3 access) are not touched, and `prevent_destroy` stops any destroy of the role.
- **The whole trust policy is replaced.** If the role must also trust another storage
  integration (e.g. the old `s3_int`), add its external ID
  (`DESC INTEGRATION <name>` → `STORAGE_AWS_EXTERNAL_ID`) to
  `additional_trusted_external_ids`. Read the diff of `assume_role_policy` in the plan.
- **One role per environment.** If DEV and PROD used the same role, each state would
  overwrite the trust policy written by the other one.

The Snowflake role needs `CREATE DATABASE` and `CREATE INTEGRATION` on the account,
and the warehouse set in the provider is used by the `COPY INTO` statements.

## Objects that already exist (import)

The native resources fail if the object already exists. Import it first
(the `snowflake_execute` tables need no import: they use `IF NOT EXISTS`):

```powershell
$m = 'module.tpcds_ingestion'
terraform -chdir=envs/dev import "$m.snowflake_database.this" 'TPCDS_DEV'
terraform -chdir=envs/dev import "$m.snowflake_schema.this" '"TPCDS_DEV"."TPCDS_PIPELINE_BRONZE"'
terraform -chdir=envs/dev import "$m.snowflake_storage_integration_aws.this" '"S3_INT_DEV"'
terraform -chdir=envs/dev import "$m.snowflake_stage_external_s3.this" '"TPCDS_DEV"."TPCDS_PIPELINE_BRONZE"."EXT_STAGE_TPCDS"'
terraform -chdir=envs/dev import "$m.snowflake_file_format_csv.this" '"TPCDS_DEV"."TPCDS_PIPELINE_BRONZE"."FF_CSV"'
terraform -chdir=envs/dev import "$m.snowflake_file_format_json.this" '"TPCDS_DEV"."TPCDS_PIPELINE_BRONZE"."FF_JSON"'
terraform -chdir=envs/dev import "$m.snowflake_file_format_parquet.this" '"TPCDS_DEV"."TPCDS_PIPELINE_BRONZE"."FF_PARQUET"'
```

Check the import ID format of each resource in the provider documentation, then run
`plan` and make sure there is no unexpected diff.

## Warnings about `snowflake_execute`

- Changing the `execute` text recreates the resource (runs `revert`, then `execute`).
  The `revert` of tables and COPY INTO is `SELECT 1` on purpose, so no table or data is
  ever dropped. A change of a table definition does **not** alter an existing table:
  run the `ALTER TABLE` yourself.
- Snowflake keeps COPY INTO load metadata for 64 days, so already loaded files are not
  loaded again. To force a new COPY INTO:
  `terraform taint 'module.tpcds_ingestion.snowflake_execute.copy_into["<table>"]'`.
- The `execute` text is stored in the state and may appear in logs: it contains no secret.
- Never put `USE ROLE` or `USE WAREHOUSE` in a statement; set them in the provider.
- DEV and PROD live in the same Snowflake account unless the provider is configured for
  another one. Storage integrations are account-level objects, hence the distinct names
  (`S3_INT_DEV`, `S3_INT_PROD`).
