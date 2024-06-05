resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_cpu" {
  name                = "alert-cpu"
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  description  = ""
  display_name = "High CPU load"
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
        | where tags contains "AlertThreshold-CPU"
        | mv-expand bagexpansion=array tags limit 400
        | extend tagName = tags[0], tagValue = tags[1]
        | where tagName == "AlertThreshold-CPU"
        | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue
        | join ( 
            InsightsMetrics
                | where Name == "UtilizationPercentage"
                | where TimeGenerated > ago(15m)
                | summarize ['% Processor']=avg(Val) by ResourceId = tolower(_ResourceId)
                )
            on ResourceId
        | where ['% Processor'] > tagValue
        | project ['% Processor'], ResourceId, name, resourceGroup, tagValue
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    dimension {
      name = "% Processor"
      operator = "Include"
      values = [ "*" ]
    }

    dimension {
      name = "name"
      operator = "Include"
      values = [ "*" ]
    }

    dimension {
      name = "resourceGroup"
      operator = "Include"
      values = [ "*" ]
    }

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
