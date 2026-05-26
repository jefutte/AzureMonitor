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
    azurerm_log_analytics_workspace.law.id
  ]
  severity = 2
  criteria {
    query                   = <<-QUERY
    arg("").resources
        | where type =~ 'microsoft.compute/virtualMachines' or type =~ "Microsoft.HybridCompute/machines"
        | where tags contains "${var.heartbeat_threshold_tag_name}"
        | mv-expand bagexpansion=array tags limit 400
      | extend tagName = tags[0], tagValue = trim(' ', tostring(tags[1]))
        | where tagName == "${var.heartbeat_threshold_tag_name}"
      | extend shortMatch = extract(@"^([0-9]+)\s*([smhdSMHD])$", 0, tagValue)
      | extend shortValue = toint(extract(@"^([0-9]+)", 1, tagValue))
      | extend shortUnit  = tolower(extract(@"^[0-9]+\s*([smhd])$", 1, tolower(tagValue)))
      | extend normalizedTagValue = case(
        tagValue contains ":" or tagValue contains ".", tagValue,
        isnotempty(shortMatch) and shortUnit == "s", strcat("0.00:00:", format_timespan(totimespan(strcat(shortValue, "s")), "ss")),
        isnotempty(shortMatch) and shortUnit == "m", strcat("0.00:", format_timespan(totimespan(strcat(shortValue, "m")), "mm:ss")),
        isnotempty(shortMatch) and shortUnit == "h", strcat("0.", format_timespan(totimespan(strcat(shortValue, "h")), "hh:mm:ss")),
        isnotempty(shortMatch) and shortUnit == "d", strcat(tostring(shortValue), ".00:00:00"),
        ""
        )
      | extend thresholdTs = totimespan(normalizedTagValue)
      | where isnotnull(thresholdTs) and thresholdTs > 0s
      | project ResourceId=tolower(id), name, resourceGroup, tagName, tagValue, thresholdTs
        | join ( 
            Heartbeat
                | summarize arg_max(TimeGenerated, *) by ResourceId = tolower(_ResourceId)
                )
            on ResourceId
      | where TimeGenerated < ago(thresholdTs)
      | project TimeGenerated, ResourceId, name, resourceGroup, tagValue, thresholdTs
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
