resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_heartbeat" {
  name                = "alert-heartbeat"
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  description  = ""
  display_name = "Missing heartbeat"
  enabled      = true

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.uami.id
    ]
  }

  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"
  scopes = [
    "/subscriptions/${data.azurerm_client_config.core.subscription_id}"
  ]
  severity = 2
  criteria {
    query                   = <<-QUERY
    arg("").resources
        | where type =~ 'microsoft.compute/virtualMachines'
        | where tags contains "AlertThreshold-Heartbeat"
        | mv-expand bagexpansion=array tags limit 400
        | extend tagName = tags[0], tagValue = tags[1]
        | where tagName == "AlertThreshold-Heartbeat"
        | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue
        | join ( 
            Heartbeat
                | summarize arg_max(TimeGenerated, *) by ResourceId = tolower(_ResourceId)
                )
            on ResourceId
        | where TimeGenerated < ago(totimespan(tagValue))
        | project TimeGenerated, ResourceId, name, resourceGroup, tagValue
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    resource_id_column = "ResourceId"
    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  auto_mitigation_enabled          = true
  workspace_alerts_storage_enabled = false

}
