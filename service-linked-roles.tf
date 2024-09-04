##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

# Entry Format:
#
# service: string
# description: string
# suffix: string
locals {
  service_linked_roles_map = { for role in var.service_linked_roles : role.service => role }
}

# The role itself
resource "aws_iam_service_linked_role" "this" {
  for_each         = local.service_linked_roles_map
  description      = try(each.value.description, "") != "" ? each.value.description : "Default Service Linked Role: ${each.value.service}"
  aws_service_name = each.value.service
  custom_suffix    = try(each.value.suffix, null)
  tags             = local.all_tags
}
