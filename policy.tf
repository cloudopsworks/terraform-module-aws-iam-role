##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

# Entry Format:
#
# name_prefix: string
# description: string
# statements:
#   - sid: string
#     effect: string
#     actions: list(string)
#     resources: list(string)
#     conditions:
#       - test: string
#         values: list(string)
#         variable: string
locals {
  policy_map = { for policy in var.policies : policy.name_prefix => policy }
}

# The role itself
resource "aws_iam_policy" "this" {
  for_each    = local.policy_map
  name        = "${each.value.name_prefix}-${local.system_name}"
  description = try(each.value.description, "") != "" ? each.value.description : "IAM Policy ${each.value.name_prefix}-${local.system_name}"
  tags        = local.all_tags
  policy      = data.aws_iam_policy_document.policy[each.key].json
}

# Inline policies
data "aws_iam_policy_document" "policy" {
  for_each = local.policy_map
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
