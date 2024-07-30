##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

data "aws_iam_policy_document" "assume_role" {
  count   = length(var.assume_role_principals) > 0 ? 1 : 0
  version = "2012-10-17"
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type        = "Service"
      identifiers = var.assume_role_principals
    }
  }
}

resource "aws_iam_role" "this" {
  name               = "${var.name_prefix}-${local.system_name}"
  assume_role_policy = length(data.aws_iam_policy_document.assume_role) > 0 ? data.aws_iam_policy_document.assume_role[0].json : null
  description        = var.description != "" ? var.description : "IAM Role ${var.name_prefix}-${local.system_name}"
  tags               = local.all_tags
}

data "aws_iam_policy" "managed" {
  for_each = toset(var.policy_attachments)
  arn      = each.value
}

data "aws_iam_policy_document" "inline" {
  for_each = var.inline_policies
  version  = "2012-10-17"
  dynamic "statement" {
    for_each = each.value.statements
    content {
      sid       = try(statement.value.sid, null)
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = statement.value.resources
      dynamic "condition" {
        for_each = try(statement.value.conditions, [])
        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.policy_attachments)
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.managed[each.key].arn
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.inline_policies
  name     = each.key
  role     = aws_iam_role.this.id
  policy   = data.aws_iam_policy_document.inline[each.key].json
}