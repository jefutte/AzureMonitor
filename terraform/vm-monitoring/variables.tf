variable "rgname" {
  type = string
}

variable "identity_name" {
  type = string
}

variable "identity_role" {
  type = string
}

variable "location" {
  type = string
}

variable "law_name" {
  type = string
}

variable "law_sku" {
  type = string
}

variable "law_retention" {
  type = string
}

variable "vmi_dcr_name" {
  type = string
}

variable "custom_dcr_name" {
  type = string
}

variable "policy_assignment_name" {
  type = string
}

variable "action_group_name" {
  type = string
}

variable "action_group_short_name" {
  type = string
}

variable "jira_webhooks" {
  type = object({
    name        = optional(string, null)
    service_uri = optional(string, null)
    sensitive   = optional(bool, true)
  })
  description = "Define Jira webhooks for sending alerts to"
  default     = null
}