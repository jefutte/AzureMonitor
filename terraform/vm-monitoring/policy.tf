locals {
    enableProcessesAndDependencies = false
    bringYourOwnUserAssignedManagedIdentity = true
    userAssignedManagedIdentityName = azurerm_user_assigned_identity.uami.name
    userAssignedManagedIdentityResourceGroup = azurerm_resource_group.monitorrg.name 
    effect = "DeployIfNotExists"
    scopeToSupportedImages = true
    dcrResourceId = azurerm_monitor_data_collection_rule.vmidcr.id
}

resource "azurerm_subscription_policy_assignment" "subpol" {
  name                 = var.policy_assignment_name
  subscription_id      = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/924bfe3a-762f-40e7-86dd-5c8b95eb09e6"

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

  identity {
    type = "SystemAssigned"
  }
}