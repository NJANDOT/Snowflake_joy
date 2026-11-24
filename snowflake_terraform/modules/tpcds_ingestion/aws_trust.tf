# Trust policy of the EXISTING AWS IAM role used by the storage integration.
#
# Snowflake assumes this role with its account-level IAM user and the external ID
# of the integration. Both values come from the integration itself, so the trust
# policy follows any (re)creation of the integration automatically.
#
# Only the trust policy is managed. The role's permission policies (S3 access)
# stay managed outside of Terraform. The role must be imported (see the import
# block in envs/<env>/main.tf) and can never be destroyed by Terraform.
#
# WARNING: this REPLACES the whole trust policy of the role. Anything else the
# role trusted must be added through var.additional_trusted_external_ids, and a
# role must not be shared by DEV and PROD (each state would overwrite the other).
resource "aws_iam_role" "snowflake_access" {
  name               = local.aws_role_name
  assume_role_policy = data.aws_iam_policy_document.snowflake_trust.json

  lifecycle {
    prevent_destroy = true

    # Attributes of the existing role that this module does not own. "path"
    # also forces a replacement, so ignoring it protects the role.
    ignore_changes = [
      description,
      tags,
      max_session_duration,
      path,
      permissions_boundary,
      force_detach_policies,
    ]
  }
}

# IAM changes are eventually consistent: wait before running COPY INTO, otherwise
# Snowflake may still be refused by sts:AssumeRole right after an update.
resource "time_sleep" "iam_propagation" {
  create_duration = "30s"

  triggers = {
    trust_policy = aws_iam_role.snowflake_access.assume_role_policy
  }
}

data "aws_iam_policy_document" "snowflake_trust" {
  statement {
    sid     = "SnowflakeStorageIntegration"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [snowflake_storage_integration_aws.this.describe_output[0].iam_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = concat(
        [snowflake_storage_integration_aws.this.describe_output[0].external_id],
        var.additional_trusted_external_ids,
      )
    }
  }
}

locals {
  # Role name is the last segment of the ARN (works with or without an IAM path).
  aws_role_name = element(reverse(split("/", var.storage_aws_role_arn)), 0)
}
