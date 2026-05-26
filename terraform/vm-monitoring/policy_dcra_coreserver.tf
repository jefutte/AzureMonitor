locals {
	dcra_coreserver_policy = jsondecode(file("${path.module}/../../AzurePolicies/AzureMonitor_DCRA_Windows_DINE.json"))
	dcra_coreserver_derived_tag_keys = distinct([
		var.cpu_threshold_tag_name,
		var.disk_warning_threshold_tag_name,
		var.disk_critical_threshold_tag_name,
		var.heartbeat_threshold_tag_name,
		var.memory_threshold_tag_name
	])
	dcra_coreserver_effective_tag_keys = length(local.dcra_coreserver_derived_tag_keys) > 0 ? local.dcra_coreserver_derived_tag_keys : var.policy_dcra_coreserver_tag_keys
}

resource "azurerm_policy_definition" "dcra_coreserver" {
	name         = var.policy_dcra_coreserver_definition_name
	display_name = var.policy_dcra_coreserver_display_name
	policy_type  = "Custom"
	mode         = try(local.dcra_coreserver_policy.mode, "Indexed")

	metadata    = jsonencode({ category = "Monitoring" })
	policy_rule = jsonencode(local.dcra_coreserver_policy.policyRule)
	parameters  = jsonencode(local.dcra_coreserver_policy.parameters)
}

resource "azurerm_subscription_policy_assignment" "subpol_dcra_coreserver" {
	name                 = var.policy_assignment_name_dcra_coreserver
	subscription_id      = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
	policy_definition_id = azurerm_policy_definition.dcra_coreserver.id
	location             = var.location

	identity {
		type = "SystemAssigned"
	}

	parameters = jsonencode({
		effect = {
			value = "DeployIfNotExists"
		}
		scopeToSupportedImages = {
			value = true
		}
		listOfWindowsImageIdToInclude = {
			value = []
		}
		dcrResourceId = {
			value = azurerm_monitor_data_collection_rule.vmidcr.id
		}
		resourceType = {
			value = "Microsoft.Insights/dataCollectionRules"
		}
		tagKeys = {
			value = local.dcra_coreserver_effective_tag_keys
		}
		listOfApplicableLocations = {
			value = var.policy_dcra_coreserver_locations
		}
	})
}

resource "azurerm_role_assignment" "role_dcra_coreserver" {
	for_each = toset([
		"Monitoring Contributor",
		"Log Analytics Contributor"
	])

	role_definition_name = each.key
	scope                = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
	principal_id         = azurerm_subscription_policy_assignment.subpol_dcra_coreserver.identity[0].principal_id
}
