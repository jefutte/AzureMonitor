resource "azurerm_resource_group" "monitorrg" {
  name = var.rgname
  location = var.location  
}