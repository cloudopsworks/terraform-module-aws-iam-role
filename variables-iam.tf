##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "name_prefix" {
  description = "The prefix to apply to the name of the IAM role"
  type        = string
}

variable "assume_role_principals" {
  description = "The ARNs of the principals (IAM users, IAM roles, and AWS services) that are allowed to assume the IAM role"
  type        = list(string)
  default     = []
}

variable "description" {
  description = "The description of the IAM role"
  type        = string
  default     = ""
}

variable "inline_policies" {
  description = "A map of inline IAM policies to attach to the IAM role"
  type        = any
  default     = {}
}

variable "policy_attachments" {
  description = "A list of ARNs of managed IAM policies names to attach to the IAM role"
  type        = list(string)
  default     = []
}