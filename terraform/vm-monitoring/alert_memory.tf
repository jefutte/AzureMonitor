resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_memory" {
  name                = "alert-memory"
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  description  = ""
  display_name = "High memory usage"
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
    azurerm_log_analytics_workspace.law.id
  ]
  severity = 2
  criteria {
    query                   = <<-QUERY
    arg("").resources
    | where type =~ 'microsoft.compute/virtualMachines' or type =~ "Microsoft.HybridCompute/machines"
    | where tags contains "AlertThreshold-RAM"
    | mv-expand bagexpansion=array tags limit 400
    | extend tagName = tags[0], tagValue = tags[1]
    | where tagName == "AlertThreshold-RAM"
    | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue
    | join ( 
        InsightsMetrics
            | where Namespace == "Memory" and Name == "AvailableMB"
            | extend memorySizeMB = todouble(parse_json(Tags).["vm.azm.ms/memorySizeMB"]) 
            | extend PercentageBytesinUse = Val/memorySizeMB*100
            | where TimeGenerated > ago(15m)
            | summarize ['% Used Memory']=avg(PercentageBytesinUse) by ResourceId = tolower(_ResourceId)
            )
        on ResourceId
    | where ['% Used Memory'] > tagValue
    | project ['% Used Memory'], ResourceId, name, resourceGroup, tagValue
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


  action {
    action_groups = [
      azurerm_monitor_action_group.actions.id
    ]
  }
}
