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

variable "cpu_threshold_tag_name" {
  type        = string
  description = "Tag key used by the CPU alert query to read threshold values."
  default     = "AlertThreshold-CPU"

  validation {
    condition     = length(trimspace(var.cpu_threshold_tag_name)) > 0
    error_message = "cpu_threshold_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.cpu_threshold_tag_name))
    error_message = "cpu_threshold_tag_name contains invalid characters."
  }
}

variable "disk_warning_threshold_tag_name" {
  type        = string
  description = "Tag key used by the disk warning alert query."
  default     = "AlertThreshold-FreeSpace"

  validation {
    condition     = length(trimspace(var.disk_warning_threshold_tag_name)) > 0
    error_message = "disk_warning_threshold_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.disk_warning_threshold_tag_name))
    error_message = "disk_warning_threshold_tag_name contains invalid characters."
  }
}

variable "disk_critical_threshold_tag_name" {
  type        = string
  description = "Tag key used by the disk critical alert query."
  default     = "AlertThreshold-DiskCritical"

  validation {
    condition     = length(trimspace(var.disk_critical_threshold_tag_name)) > 0
    error_message = "disk_critical_threshold_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.disk_critical_threshold_tag_name))
    error_message = "disk_critical_threshold_tag_name contains invalid characters."
  }
}

variable "heartbeat_threshold_tag_name" {
  type        = string
  description = "Tag key used by the heartbeat alert query."
  default     = "AlertThreshold-Heartbeat"

  validation {
    condition     = length(trimspace(var.heartbeat_threshold_tag_name)) > 0
    error_message = "heartbeat_threshold_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.heartbeat_threshold_tag_name))
    error_message = "heartbeat_threshold_tag_name contains invalid characters."
  }
}

variable "memory_threshold_tag_name" {
  type        = string
  description = "Tag key used by the memory alert query."
  default     = "AlertThreshold-RAM"

  validation {
    condition     = length(trimspace(var.memory_threshold_tag_name)) > 0
    error_message = "memory_threshold_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.memory_threshold_tag_name))
    error_message = "memory_threshold_tag_name contains invalid characters."
  }
}

variable "services_alert_tag_name" {
  type        = string
  description = "Tag key used by the services alert query."
  default     = "Alert-Services"

  validation {
    condition     = length(trimspace(var.services_alert_tag_name)) > 0
    error_message = "services_alert_tag_name must not be empty."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9._:-]+$", var.services_alert_tag_name))
    error_message = "services_alert_tag_name contains invalid characters."
  }
}

variable "policy_dcra_coreserver_definition_name" {
  type        = string
  description = "Name of the custom policy definition for DCRA Core Server Windows scope."
  default     = "ConfigureDCRACoreServerWindows"

  validation {
    condition     = length(trimspace(var.policy_dcra_coreserver_definition_name)) > 0
    error_message = "policy_dcra_coreserver_definition_name must not be empty."
  }
}

variable "policy_dcra_coreserver_display_name" {
  type        = string
  description = "Display name of the custom policy definition for DCRA Core Server Windows scope."
  default     = "Configure Windows Machines with DCRA (Core Server)"

  validation {
    condition     = length(trimspace(var.policy_dcra_coreserver_display_name)) > 0
    error_message = "policy_dcra_coreserver_display_name must not be empty."
  }
}

variable "policy_assignment_name_dcra_coreserver" {
  type        = string
  description = "Subscription assignment name for custom DCRA Core Server policy."
  default     = "Enable Azure Monitor DCRA for Core Server Windows"

  validation {
    condition     = length(trimspace(var.policy_assignment_name_dcra_coreserver)) > 0
    error_message = "policy_assignment_name_dcra_coreserver must not be empty."
  }
}

variable "policy_dcra_coreserver_tag_keys" {
  type        = list(string)
  description = "Tag keys; policy applies if at least one key exists on the resource."
  default     = ["Monitor"]

  validation {
    condition = length(var.policy_dcra_coreserver_tag_keys) > 0 && alltrue([
      for k in var.policy_dcra_coreserver_tag_keys : length(trimspace(k)) > 0
    ])
    error_message = "policy_dcra_coreserver_tag_keys must contain at least one non-empty tag key."
  }
}

variable "policy_dcra_coreserver_locations" {
  type        = list(string)
  description = "Locations where the custom DCRA Core Server policy applies."
  default     = ["westeurope"]

  validation {
    condition = length(var.policy_dcra_coreserver_locations) > 0 && alltrue([
      for l in var.policy_dcra_coreserver_locations : length(trimspace(l)) > 0
    ])
    error_message = "policy_dcra_coreserver_locations must contain at least one non-empty location."
  }
}