resource "azurerm_monitor_data_collection_rule" "vmidcr" {
  name                = var.vmi_dcr_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  data_sources {
    performance_counter {
      streams = [
        "Microsoft-InsightsMetrics"
      ]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "\\VmInsights\\DetailedMetrics"
      ]
      name = "VMInsightsPerfCounters"
    }
  }

  destinations {
    log_analytics {
      workspace_resource_id = azurerm_log_analytics_workspace.law.id
      name                  = "VMInsightsPerf-Logs-Dest"
    }
  }

  data_flow {
    streams = [
      "Microsoft-InsightsMetrics"
    ]
    destinations = [
      "VMInsightsPerf-Logs-Dest"
    ]
  }

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}
 