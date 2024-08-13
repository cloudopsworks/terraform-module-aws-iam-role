##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

locals {
  roles_map = { for role in var.roles : role.name_prefix => role }
  managed_policies = merge(
    [
      for role in var.roles : {
        for policy_arn in try(role.managed_policies, []) : "${role.name_prefix}-${policy_arn}" => {
          name_prefix = role.name_prefix
          policy_arn  = policy_arn
        }
      }
  ]...)
  inline_policies = merge(
    [
      for role in var.roles : {
        for policy in try(role.inline_policies, []) : "${role.name_prefix}-${policy.name}" => {
          name_prefix = role.name_prefix
          name        = policy.name
          statements  = policy.statements
        }
      }
  ]...)
  assume_role_principals = {
    for role in var.roles : role.name_prefix => {
      name_prefix = role.name_prefix
      actions     = concat(try(role.assume_role.actions, []), ["sts:AssumeRole"])
      type        = try(role.assume_role.type, "Service")
      principals  = try(role.assume_role.principals, ["ec2.amazonaws.com"])
    }
  }
}

# STS Assume
data "aws_iam_policy_document" "assume_role" {
  for_each = local.assume_role_principals
  version  = "2012-10-17"
  statement {
    effect  = "Allow"
    actions = each.value.actions
    principals {
      type        = each.value.type
      identifiers = each.value.principals
    }
    dynamic "condition" {
      for_each = try(each.value.conditions, [])
      content {
        test     = condition.value.test
        values   = condition.value.values
        variable = condition.value.variable
      }
    }
  }
}

# The role itself
resource "aws_iam_role" "this" {
  for_each           = local.roles_map
  name               = "${each.value.name_prefix}-${local.system_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role[each.key].json
  description        = each.value.description != "" ? each.value.description : "IAM Role ${each.value.name_prefix}-${local.system_name}"
  tags               = local.all_tags
}

data "aws_iam_policy" "managed" {
  for_each = local.managed_policies
  arn      = each.value.policy_arn
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = local.managed_policies
  role       = aws_iam_role.this[each.value.role_prefix].name
  policy_arn = data.aws_iam_policy.managed[each.key].arn
}

# Inline policies
data "aws_iam_policy_document" "inline" {
  for_each = local.inline_policies
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

resource "aws_iam_role_policy" "inline" {
  for_each = local.inline_policies
  name     = each.value.name
  role     = aws_iam_role.this[each.value.name_prefix].id
  policy   = data.aws_iam_policy_document.inline[each.key].json
}