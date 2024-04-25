locals {
  parameters = jsonencode({
    "enableProcessesAndDependencies" = {
      value = false
    }
    "bringYourOwnUserAssignedManagedIdentity" = {
      value = true
    }
    "userAssignedManagedIdentityName" : {
      value = "${azurerm_user_assigned_identity.name}"
    }
    "userAssignedManagedIdentityResourceGroup" : {
      value = "${azurerm_resource_group.name}"
    }
    "effect" : {
      value = "DeployIfNotExists"
    }
    "scopeToSupportedImages" : {
      value = true
    }
    "dcrResourceId" : {
      value = "${azurerm_monitor_data_collection_rule.id}"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "subpol" {
  name                 = var.policy_assignment_name
  subscription_id      = data.azurerm_client_config.core.subscription_id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"

  parameters = local.parameters
}