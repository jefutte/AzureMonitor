resource "azurerm_monitor_action_group" "actions" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  short_name          = var.action_group_short_name

  webhook_receiver {
    name                    = "jira"
    service_uri             = var.action_group_webhook
    use_common_alert_schema = true
  }
}