##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

output "iam_roles" {
  value = [
    for role in aws_iam_role.this : {
      name = role.name
      arn  = role.arn
    }
  ]
}

output "iam_policies" {
  value = [
    for role in aws_iam_policy.this : {
      name = role.name
      arn  = role.arn
    }
  ]
}
