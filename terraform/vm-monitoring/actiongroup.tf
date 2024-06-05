locals {
  webhook = var.webhooks[0].service_uri
}

resource "azurerm_monitor_action_group" "actions" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  short_name          = var.action_group_short_name

  dynamic "webhook_receiver" {
    for_each = var.webhooks

    content {
      name                    = var.webhooks.name
      service_uri             = local.webhook
      use_common_alert_schema = var.webhooks.use_common_alert_schema
    }
  }
}