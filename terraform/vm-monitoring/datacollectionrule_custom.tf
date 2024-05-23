resource "azurerm_monitor_data_collection_rule" "customdcr" {
  name                = var.custom_dcr_name
  resource_group_name = azurerm_resource_group.monitorrg.name
  location            = var.location

  data_sources {
    performance_counter {
      streams = [
        "Microsoft-Perf"
      ]
      sampling_frequency_in_seconds = 60
      counter_specifiers = [
        "Memory\\Available MBytes",
        "Processor(_Total)\\% Processor Time"
      ]
      name = "Perf"
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
      "Microsoft-Perf"
    ]
    destinations = [
      "VMInsightsPerf-Logs-Dest"
    ]
  }

  depends_on = [
    azurerm_log_analytics_workspace.law
  ]
}
