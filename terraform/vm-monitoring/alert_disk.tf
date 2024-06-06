resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_disk_warning" {
  name                = "alert-disk-warning"
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  description  = ""
  display_name = "Low disk space warning"
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
      | where type =~ 'microsoft.compute/virtualMachines' or type =~ "Microsoft.HybridCompute/machines"
      | where tags contains "AlertThreshold-FreeSpace"
      | mv-expand bagexpansion=array tags limit 400
      | extend tagName = tags[0], tagValue = tags[1]
      | where tagName == "AlertThreshold-FreeSpace"
      | project ResourceId=tolower(id), name, resourceGroup, tagValue
      | extend thresholdArray = split(tagValue, ";")
      | mv-expand thresholdArray limit 400
      | extend mountIdThresholdPair = split(thresholdArray, ":")
      | extend mountId = tostring(mountIdThresholdPair[0]), thresholdValue = todouble(mountIdThresholdPair[1])
      | join (
          InsightsMetrics
          | where Name == "FreeSpacePercentage"
          | where TimeGenerated > ago(15m)
          | extend mountId = trim_end(":",tostring(parse_json(Tags)['vm.azm.ms/mountId']))
          | summarize ['% FreeSpace']=avg(Val) by ResourceId = tolower(_ResourceId), mountId
      ) on ResourceId, mountId
      | where ['% FreeSpace'] < thresholdValue
      | project ['% FreeSpace'], ResourceId, name, resourceGroup, mountId, thresholdValue
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



resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert_disk_critical" {
  name                = "alert-disk-critical"
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  description  = "Disk space is critically low"
  display_name = "Low disk space critical"
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
  severity = 0
  criteria {
    query                   = <<-QUERY
      arg("").resources
      | where type =~ 'microsoft.compute/virtualMachines'
      | where tags contains "AlertThreshold-DiskCritical"
      | mv-expand bagexpansion=array tags limit 400
      | extend tagName = tags[0], tagValue = tags[1]
      | where tagName == "AlertThreshold-DiskCritical"
      | project ResourceId=tolower(id), name, resourceGroup, tagValue
      | extend thresholdArray = split(tagValue, ";")
      | mv-expand thresholdArray limit 400
      | extend mountIdThresholdPair = split(thresholdArray, ":")
      | extend mountId = tostring(mountIdThresholdPair[0]), thresholdValue = todouble(mountIdThresholdPair[1])
      | join (
          InsightsMetrics
          | where Name == "FreeSpacePercentage"
          | where TimeGenerated > ago(15m)
          | extend mountId = trim_end(":",tostring(parse_json(Tags)['vm.azm.ms/mountId']))
          | summarize ['% FreeSpace']=round(avg(Val),2) by ResourceId = tolower(_ResourceId), mountId
      ) on ResourceId, mountId
      | where ['% FreeSpace'] < thresholdValue
      | project ['% FreeSpace'], ResourceId, name, resourceGroup, mountId, thresholdValue
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
