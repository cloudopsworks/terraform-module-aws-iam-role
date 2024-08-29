##
# (c) 2024 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#

variable "roles" {
  description = "A list of IAM roles to create"
  type        = any
  default     = []
}

variable "policies" {
  description = "A list of IAM policies to create"
  type        = any
  default     = []
}
