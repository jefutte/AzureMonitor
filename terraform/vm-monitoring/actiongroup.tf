resource "azurerm_monitor_action_group" "actions" {
  name = var.action_group_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  short_name = var.action_group_short_name

  dynamic "webhook_receiver" {
    for_each = var.jira_webhooks

    content {
        name = var.jira_webhook.name
        service_uri = var.jira_webhook.service_uri
        use_common_alert_schema = var.jira_webhook.use_common_alert_schema
    }
  }
}