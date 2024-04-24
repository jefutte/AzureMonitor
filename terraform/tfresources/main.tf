data "azurerm_resource_group" "rg" {
  name = var.rgname
}

data "azurerm_user_assigned_identity" "identity" {
  name                = var.identityname
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_storage_account" "stg" {
  name                     = var.stgname
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "container" {
  name                  = "terraform"
  storage_account_name  = azurerm_storage_account.stg.name
  container_access_type = private
}

resource "azurerm_role_assignment" "role" {
  scope                = azurerm_storage_account.stg.id
  role_definition_name = "Owner"
  principal_id         = data.azurerm_user_assigned_identity.identity.principal_id
}