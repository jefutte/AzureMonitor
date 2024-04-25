resource "azurerm_user_assigned_identity" "uami" {
  name                = var.identity_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location
}

resource "azurerm_role_assignment" "uamirole" {
  scope                = "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  role_definition_name = var.identity_role
  principal_id         = azurerm_user_assigned_identity.uami.principal_id
}