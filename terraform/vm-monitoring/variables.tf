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

variable "policy_assignment_name_hybrid" {
  type = string
}

variable "action_group_name" {
  type = string
}

variable "action_group_short_name" {
  type = string
}

variable "action_group_webhook" {
  type      = string
  sensitive = true
  default = ""
}