resource "azurerm_log_analytics_workspace" "law" {
  name = var.law_name
  location = var.location
  resource_group_name = azurerm_resource_group.monitorrg.name
  sku = var.law_sku
  retention_in_days = var.law_retention
}