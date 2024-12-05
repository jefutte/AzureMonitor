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
    azurerm_log_analytics_workspace.law.id
  ]
  severity = 2
  criteria {
    query                   = <<-QUERY
    arg("").resources
    | where type =~ 'microsoft.compute/virtualMachines' or type =~ "Microsoft.HybridCompute/machines"
    | where tags contains "Alert-Services"
    | mv-expand bagexpansion=array tags limit 400
    | extend tagName = tags[0], tagValue = tags[1]
    | where tagName == "Alert-Services"
    | project ResourceId=tolower(id), name, resourceGroup, tagValue
    | extend servicesArray = split(tagValue, ";")
    | mv-expand servicesArray limit 400
    | join (
        ConfigurationChange
        | where SvcName == "Spooler"
        | project ResourceId = tolower(_ResourceId), Computer, TimeGenerated, SvcPreviousState, SvcState, SvcDisplayName, SvcStartupType
    ) on ResourceId
    QUERY
    time_aggregation_method = "Count"
    threshold               = 0
    operator                = "GreaterThan"

    dimension {
      name     = "% Processor"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "name"
      operator = "Include"
      values   = ["*"]
    }

    dimension {
      name     = "resourceGroup"
      operator = "Include"
      values   = ["*"]
    }

    resource_id_column = "ResourceId"
    failing_periods {
      number_of_evaluation_periods             = 1
      minimum_failing_periods_to_trigger_alert = 1
    }
  }

  auto_mitigation_enabled          = true
  workspace_alerts_storage_enabled = false

}
