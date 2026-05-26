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

  validation {
    condition     = contains(["PerGB2018", "CapacityReservation", "Free", "LACluster"], var.law_sku)
    error_message = "law_sku must be one of: PerGB2018, CapacityReservation, Free, LACluster."
  }
}

variable "law_retention" {
  type = number

  validation {
    condition     = var.law_retention >= 30 && var.law_retention <= 730
    error_message = "law_retention must be between 30 and 730 days."
  }
}

variable "vmi_dcr_name" {
  type = string
}

variable "ct_dcr_name" {
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

  validation {
    condition     = length(trimspace(var.action_group_short_name)) > 0 && length(var.action_group_short_name) <= 12
    error_message = "action_group_short_name must be non-empty and at most 12 characters."
  }
}

variable "action_group_webhook" {
  type      = string
  sensitive = true
  default   = ""
}