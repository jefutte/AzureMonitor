locals {
  enableProcessesAndDependencies           = false
  bringYourOwnUserAssignedManagedIdentity  = true
  userAssignedManagedIdentityName          = azurerm_user_assigned_identity.uami.name
  userAssignedManagedIdentityResourceGroup = azurerm_resource_group.monitorrg.name
  effect                                   = "DeployIfNotExists"
  scopeToSupportedImages                   = true
  dcrResourceId                            = azurerm_monitor_data_collection_rule.vmidcr.id
  azRoles = toset([
    "Contributor",
    "User Access Administrator",
    "Virtual Machine Contributor",
    "Log Analytics Contributor",
    "Monitoring Contributor"
  ])
  hybridRoles = toset([
    "Azure Connected Machine Resource Administrator",
    "Log Analytics Contributor",
    "Monitoring Contributor"
  ])
}

resource "azurerm_subscription_policy_assignment" "subpol" {
  name                 = var.policy_assignment_name
  subscription_id      = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode(
    {
      "enableProcessesAndDependencies" = {
        value = local.enableProcessesAndDependencies
      }
      "bringYourOwnUserAssignedManagedIdentity" = {
        value = local.bringYourOwnUserAssignedManagedIdentity
      }
      "userAssignedManagedIdentityName" : {
        value = local.userAssignedManagedIdentityName
      }
      "userAssignedManagedIdentityResourceGroup" : {
        value = local.userAssignedManagedIdentityResourceGroup
      }
      "effect" : {
        value = local.effect
      }
      "scopeToSupportedImages" : {
        value = local.scopeToSupportedImages
      }
      "dcrResourceId" : {
        value = local.dcrResourceId
      }
    }
  )
}

resource "azurerm_role_assignment" "role_az" {
  for_each = local.azRoles

  role_definition_name = each.key
  scope                = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  principal_id         = azurerm_subscription_policy_assignment.subpol.identity[0].principal_id
}


resource "azurerm_subscription_policy_assignment" "subpol_hybrid" {
  name                 = var.policy_assignment_name_hybrid
  subscription_id      = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/2b00397d-c309-49c4-aa5a-f0b2c5bc6321"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  parameters = jsonencode(
    {
      "enableProcessesAndDependencies" = {
        value = local.enableProcessesAndDependencies
      }
      "effect" : {
        value = local.effect
      }
      "dcrResourceId" : {
        value = local.dcrResourceId
      }
    }
  )
}

resource "azurerm_role_assignment" "role_hybrid" {
  for_each = local.hybridRoles

  role_definition_name = each.key
  scope                = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  principal_id         = azurerm_subscription_policy_assignment.subpol_hybrid.identity[0].principal_id
}