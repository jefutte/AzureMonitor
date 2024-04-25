data "azurerm_resource_group" "rg" {
  name = var.rgname
}

data "azurerm_user_assigned_identity" "identity" {
  name                = var.identityname
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_resource_group" "monitorrg" {
  name = var.rgname
  location = var.location  
}